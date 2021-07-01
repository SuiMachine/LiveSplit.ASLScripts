// This was inially based on Ero's, but was later expended by the fantastic Mono Bucket Scanner that Ero and Micrologist  wrote.
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

	vars.TimerStart = (EventHandler) ((s, e) => vars.CompletedSplits.Clear());
	timer.OnStart += vars.TimerStart;
}

init
{
	vars.SigFound = false;
	vars.TokenSource = new CancellationTokenSource();
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
				print("Found scene manager, initiating mono scan to get the rest");
				
				uint ASM_CS_HASH = 0xFA381AED;
				int PTR_SIZE = 0x8;
				// size, items, next
				int[] OFFSETS_TABLE = { 0x18,  0x10, 0x10 };
				// cache, size, items
				int[] OFFSETS_CACHE = { 0x4C0, 0x18, 0x20 };
				// parent, name, space, static, fields, runtime, next
				int[] OFFSETS_KLASS = { 0x30, 0x48, 0x50, 0x60, 0x98, 0xD0, 0x108 };
				// next, name, offset
				int[] OFFSETS_FIELD = { 0x20,  0x8, 0x18 };

				SignatureScanner MonoScanner = null;
				var mono_image_loaded = new SigScanTarget(3, "48 8B 0D ???????? 48 8B D7 E8 ???????? 48 8B D8 83 3D ???????? 00");
				mono_image_loaded.OnFound = (p, s, ptr) => ptr + 0x4 + p.ReadValue<int>(ptr);
				IntPtr loaded_images = IntPtr.Zero, Asm_Cs_image = IntPtr.Zero;
				
				vars.Mono = new Dictionary<string, Dictionary<string, IntPtr>>();

				while (!Token.IsCancellationRequested)
				{
					var Mono = game.ModulesWow64Safe().FirstOrDefault(m => m.ModuleName.StartsWith("mono"));
					if (Mono == null)
					{
						vars.Dbg("Could not find Mono module. Trying again.");
						Thread.Sleep(2000);
						continue;
					}
					MonoScanner = new SignatureScanner(game, Mono.BaseAddress, Mono.ModuleMemorySize);
					break;
				}

				while (!Token.IsCancellationRequested)
				{
					loaded_images = MonoScanner.Scan(mono_image_loaded);
					if (loaded_images == IntPtr.Zero)
					{
						vars.Dbg("Could not resolve mono_image_loaded signature. Trying again.");
						Thread.Sleep(2000);
						continue;
					}
					break;
				}

				while (!Token.IsCancellationRequested)
				{
					var ghashtable = IntPtr.Zero;
					var size = new DeepPointer(loaded_images, OFFSETS_TABLE[0]).Deref<int>(game);
					new DeepPointer(loaded_images, OFFSETS_TABLE[1], PTR_SIZE * (int)(ASM_CS_HASH % size)).DerefOffsets(game, out ghashtable);

					for (var ptr = game.ReadPointer(ghashtable); ptr != IntPtr.Zero; ptr = game.ReadPointer(ptr + OFFSETS_TABLE[2]))
					{
						string name = new DeepPointer(ptr, 0x0).DerefString(game, 32, "");
						if (name != "Assembly-CSharp") continue;
						Asm_Cs_image = game.ReadPointer(ptr + PTR_SIZE);
						break;
					}
					
					if (Asm_Cs_image == IntPtr.Zero)
					{
						vars.Dbg("Assembly-CSharp was not found in the loaded images. Trying again.");
						Thread.Sleep(2000);
						continue;
					}
					break;
				}

				Func<string, string> cleanString = (input) =>
				{
					if (input.Contains("BackingField")) input = System.Text.RegularExpressions.Regex.Matches(input, @"<(.+)>k__BackingField")[0].Groups[1].Value;
					if (input.Contains("`")) input = input.Remove(input.IndexOf("`"));
					return input;
				};

				Func<IntPtr, Dictionary<string, IntPtr>> findStatics = (klass) =>
				{
					var fields = new Dictionary<string, IntPtr>();
					IntPtr mono_fields = game.ReadPointer(klass + OFFSETS_KLASS[4]), ptr = game.ReadPointer(mono_fields + OFFSETS_FIELD[1]);

					for (int i = 0; ptr != IntPtr.Zero; i += OFFSETS_FIELD[0], ptr = game.ReadPointer(mono_fields + OFFSETS_FIELD[1] + i))
					{
						var type = new DeepPointer(mono_fields + i, PTR_SIZE).Deref<short>(game);
						var name = cleanString(new DeepPointer(mono_fields + OFFSETS_FIELD[1] + i, 0x0).DerefString(game, 64, ""));
						var offset = game.ReadValue<int>(mono_fields + OFFSETS_FIELD[2] + i);
						if (string.IsNullOrEmpty(name) || type < 0x10 || type > 0x17 || fields.ContainsKey(name)) continue;

						vars.Dbg("    Found field " + name + " (0x" + offset.ToString("X") + ")");
						fields.Add(name, new DeepPointer(klass + OFFSETS_KLASS[5], PTR_SIZE, OFFSETS_KLASS[3]).Deref<IntPtr>(game) + offset);
					}

					return fields;
				};

				while (!Token.IsCancellationRequested)
				{
					var size = game.ReadValue<int>(Asm_Cs_image + OFFSETS_CACHE[0] + OFFSETS_CACHE[1]);
					var monovtable = game.ReadPointer(Asm_Cs_image + OFFSETS_CACHE[0] + OFFSETS_CACHE[2]);

					if (size == 0)
					{
						vars.Dbg("Class cache is empty. Wrong offsets? Trying again.");
						vars.Dbg(size);
						Thread.Sleep(2000);
						continue;
					}

					for (int i = 0; i < size; ++i)
					{
						for (var klass = game.ReadPointer(monovtable + PTR_SIZE * i); klass != IntPtr.Zero; klass = game.ReadPointer(klass + OFFSETS_KLASS[6]))
						{
							string class_namespace = new DeepPointer(klass + OFFSETS_KLASS[2], 0x0).DerefString(game, 128, "default");
							if (class_namespace.Length > 0) continue;

							string class_name = new DeepPointer(klass + OFFSETS_KLASS[1], 0x0).DerefString(game, 128, "");
							if (vars.Mono.ContainsKey(class_name) || string.IsNullOrEmpty(class_name)) continue;

							//vars.Dbg("Found class " + class_name + " (0x" + klass.ToString("X") + ")");
							
							var static_fields = findStatics(klass);
							if (static_fields.Count <= 0) continue;

							//vars.Dbg(string.Format("Added class '{0}' with fields\n{1}", class_name, string.Join(",\n", static_fields.Keys)));
							vars.Mono.Add(class_name, static_fields);
						}
					}

					break;
				}

				vars.Dbg("Exiting mono scan thread.");
		
				Func<string, string> PathToName = (path) =>
				{
					if (String.IsNullOrEmpty(path) || !path.StartsWith("Assets/"))
						return null;
					else
						return System.Text.RegularExpressions.Regex.Matches(path, @".+/(.+).unity")[0].Groups[1].Value;
				};
				
				if(vars.Mono.ContainsKey("GameManager"))
				{
					var gm = vars.Mono["GameManager"];
					if(gm.ContainsKey("LoadingQuickSave"))
						vars.LoadingQuickSave = gm["LoadingQuickSave"];
					else
					{
						vars.Dbg("No loading quick save... exiting.");
						break;
					}
					
					if(gm.ContainsKey("GAME_STATE"))
						vars.pointerGameState = gm["GAME_STATE"];
					else
					{
						vars.Dbg("No game state... exiting.");
						break;
					}

					vars.UpdateScenes = (Action) (() =>
					{
						current.ThisScene = PathToName(new DeepPointer(SceneManagerBindings, 0x48, 0x10, 0x0).DerefString(game, 73)) ?? old.ThisScene;
						current.NextScene = PathToName(new DeepPointer(SceneManagerBindings, 0x28, 0x0, 0x10, 0x0).DerefString(game, 73)) ?? old.NextScene;
						current.loadingQuickSave = game.Read<byte>(vars.pointerLoadingQuickSave);
						current.gameState = game.Read<byte>(vars.pointerGameManager);
					});
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
}