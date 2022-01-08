// The code for figuring out addresses of static fields was provided by Ero.
// I (Suicide Machine) only adopted it Viscerafest and reversed the pointer to SceneManagerBinding.

state("viscerafest") {}

startup
{
	var SplitScenes = new List<string>
	{
		"Intro Level",
		"C1L1",
		"C1L2",
		"C1L3",
		"C1L4",
		"C1L5",
		"C1L6",
		"C1L7"
	};
	
	vars.AdditionalPauses = new List<string> { "Menu" };
	vars.Dbg = (Action<dynamic>) ((output) => print("[Mono ASL] " + output));

	settings.Add("sceneSplits", true, "Split after finishing a scene:");
	foreach (string scene in SplitScenes)
		settings.Add(scene, true, scene, "sceneSplits");
		
	if(!((IDictionary<String, object>)vars).ContainsKey("CompletedSplits"))
		vars.CompletedSplits = new List<string>();
		
	vars.TimerStart = (EventHandler) ((s, e) => vars.CompletedSplits.Clear());
	timer.OnStart += vars.TimerStart;
	vars.TokenSource = new CancellationTokenSource();
}

init
{
	vars.SigFound = false;
	vars.CompletedSplits = new List<string>();
	current.ThisScene = "";
	current.NextScene = "";
	current.gameState = 0;
	current.loadingQuickSave = false;
	vars.pointerGameState = IntPtr.Zero;
	vars.pointerLoadingQuickSave = IntPtr.Zero;
	vars.UpdateScenes = (Action) (() => {});
	
	vars.SigThread = new Thread(() =>
	{
		print("Starting signature thread.");
		
		var SceneManagerBindings = IntPtr.Zero;
		
		//SceneManagerBindings::GetActiveScene
		var SceneManagerBindingsSig = new SigScanTarget(5, "48 83 EC 28" +
			"E8 ?? ?? ?? ??" +
			"48 8B C8" +
			"E8 ?? ?? ?? ??" +
			"48 85 C0" +
			"74 08" +
			"8B 40 08" +
			"48 83 C4 28" +
			"C3" +
			"48 83 C4 28" +
			"C3");
		SceneManagerBindingsSig.OnFound = (p, s, ptr) => IntPtr.Add(ptr + 4, p.ReadValue<int>(ptr));
		
		var Token = vars.TokenSource.Token;
		while (!Token.IsCancellationRequested)
		{
			var GameModules = game.ModulesWow64Safe();
			
			var UnityPlayerModule = GameModules.FirstOrDefault(m => m.ModuleName == "UnityPlayer.dll");
			
			if (UnityPlayerModule == null)
			{
				Thread.Sleep(2000);
				continue;
			}
			
			var UnityPlayerScanner = new SignatureScanner(game, UnityPlayerModule.BaseAddress, UnityPlayerModule.ModuleMemorySize);
			
			if (SceneManagerBindings == IntPtr.Zero && (SceneManagerBindings = UnityPlayerScanner.Scan(SceneManagerBindingsSig)) != IntPtr.Zero)
			{
				//print("Mov instruction of SceneManagerBindings: " + SceneManagerBindings.ToString("X8"));
				SceneManagerBindings = IntPtr.Add(SceneManagerBindings + 7, game.ReadValue<int>(SceneManagerBindings + 3));
				print("Found SceneManagerBinding: 0x" + SceneManagerBindings.ToString("X16"));
			}
			
			vars.SigFound = SceneManagerBindings != IntPtr.Zero;

			if (!vars.SigFound)
			{
				Thread.Sleep(2000);
				if(SceneManagerBindings == IntPtr.Zero)
					print("Scene Manager is null");
			}
			else
			{
				vars.Dbg("Starting mono scan.");
				var classes = new Dictionary<string, bool>
				{
					{ "GameManager", false /* does this class derive from a Singleton<T> (or similar) */ }
				};
				
				IntPtr loaded_images = new DeepPointer("mono-2.0-bdwgc.dll", 0x49B0C8).Deref<IntPtr>(game);
				int size = game.ReadValue<int>(loaded_images + 0x18);
				IntPtr table = new DeepPointer(loaded_images + 0x10, 0x8 * (int)(0xFA381AED % size)).Deref<IntPtr>(game);
				IntPtr asm_cs_image = IntPtr.Zero;
				for (; table != IntPtr.Zero; table = game.ReadPointer(table + 0x10))
				{
					if (new DeepPointer(table, 0x0).DerefString(game, 32) != "Assembly-CSharp")
						continue;
					size = new DeepPointer(table + 0x8, 0x4D8).Deref<int>(game);
					asm_cs_image = new DeepPointer(table + 0x8, 0x4E0).Deref<IntPtr>(game);
				}
				
				vars.Mono = new Dictionary<string, IntPtr>();

				for (int i = 0; i < size; ++i, table = game.ReadPointer(asm_cs_image + 0x8 * i))
				{
					for (; table != IntPtr.Zero; table = game.ReadPointer(table + 0x108))
					{
						string class_name = new DeepPointer(table + 0x48, 0x0).DerefString(game, 64, "");
						
						if (!classes.ContainsKey(class_name))
							continue;
						vars.Mono[class_name] = classes[class_name]
												? new DeepPointer(table + 0x30, 0xD0, 0x8, 0x60).Deref<IntPtr>(game)
												: new DeepPointer(table + 0xD0, 0x8, 0x60).Deref<IntPtr>(game);
					}

					if (vars.Mono.Count == classes.Count)
						break;
				}

				vars.Dbg("Exiting mono scan.");
		
				Func<string, string> PathToName = (path) =>
				{
					if (String.IsNullOrEmpty(path) || !path.StartsWith("Assets/"))
						return null;
					else
						return System.Text.RegularExpressions.Regex.Matches(path, @".+/(.+).unity")[0].Groups[1].Value;
				};
				
				foreach(var element in vars.Mono)
				{
					vars.Dbg(element);
				}				
				
				if(vars.Mono.ContainsKey("GameManager"))
				{
					var gm = vars.Mono["GameManager"];
					{
						vars.pointerGameState = gm + 0x0; //gameState 
						vars.pointerLoadingQuickSave = gm + 0x51; //QuickSaveLoading
					}

					vars.UpdateScenes = (Action) (() =>
					{
						current.ThisScene = PathToName(new DeepPointer(SceneManagerBindings, 0x48, 0x10, 0x0).DerefString(game, 73)) ?? old.ThisScene;
						current.NextScene = PathToName(new DeepPointer(SceneManagerBindings, 0x28, 0x0, 0x10, 0x0).DerefString(game, 73)) ?? old.NextScene;
						current.loadingQuickSave = new DeepPointer(vars.pointerLoadingQuickSave).Deref<bool>(game);
						current.gameState = new DeepPointer(vars.pointerGameState).Deref<int>(game);
					});
					vars.Dbg("Pointers set!");
					break;
				}
				else
				{
					vars.Dbg("No Game manager. Exiting... :(");
					break;
				}
			}
		}
		
		print("Exiting signature thread.");
	});
	vars.SigThread.Start();
}

update
{
	if (!vars.SigFound)
		return false;
	vars.UpdateScenes();
}

start
{
	return old.ThisScene != current.ThisScene && old.ThisScene == "Menu";
}

split
{
	if ((old.NextScene != current.NextScene || (old.gameState != current.gameState && current.gameState == 4 && current.NextScene == "C1L7")) && 
		current.NextScene != "Menu" && old.NextScene != "Menu" &&
		!vars.CompletedSplits.Contains(old.NextScene))
	{
		vars.CompletedSplits.Add(old.NextScene);
		return settings[old.NextScene];
	}
}


reset
{
	return old.ThisScene == "Menu" &&
		   current.ThisScene == "Intro Level";
}

isLoading
{
	return current.ThisScene != current.NextScene || current.loadingQuickSave;
}

exit
{
	vars.TokenSource.Cancel();
}

shutdown
{
	vars.TokenSource.Cancel();
	timer.OnStart -= vars.TimerStart;
}