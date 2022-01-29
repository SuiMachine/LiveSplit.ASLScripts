state("filcher")
{
}

startup
{	
	vars.TokenSource = new CancellationTokenSource();
	vars.Dbg = (Action<dynamic>) ((output) => print("[Mono ASL] " + output));
}

init
{
	vars.SigFound = false;
	vars.UpdateScenes = (Action) (() => {});
	current.GameScriptIsPaused = false;
	
	vars.SigThread = new Thread(() =>
	{
		//MOno + 0x4980C0
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
			
			vars.Dbg("Starting mono scan.");
			var classes = new Dictionary<string, bool>
			{
				{ "GameScript", false /* does this class derive from a Singleton<T> (or similar) */ },
				{ "UIHandler", false /* does this class derive from a Singleton<T> (or similar) */ }
			};
			
			IntPtr loaded_images = new DeepPointer("mono-2.0-bdwgc.dll", 0x4980C0).Deref<IntPtr>(game);
			
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
			
			for (int i = 0; i < size; ++i)
			{
				table = game.ReadPointer(asm_cs_image + 0x8 * i);
				for (; table != IntPtr.Zero; table = game.ReadPointer(table + 0x108))
				{
					string class_name = new DeepPointer(table + 0x48, 0x0).DerefString(game, 64, "");
					
					if (!classes.ContainsKey(class_name))
						continue;
					vars.Mono[class_name] = classes[class_name]
											? new DeepPointer(table + 0x30, 0xD0, 0x8, 0x60).Deref<IntPtr>(game)
											: new DeepPointer(table + 0xD0, 0x8, 0x60).Deref<IntPtr>(game);
					vars.Dbg("Adding:" + class_name);
				}
			
				if (vars.Mono.Count == classes.Count)
					break;
			}
			
			vars.Dbg("Exiting mono scan.");
			
		
			foreach(var element in vars.Mono)
			{
				vars.Dbg(element);
			}				
			
			if(vars.Mono.ContainsKey("GameScript") && vars.Mono.ContainsKey("UIHandler"))
			{
				IntPtr gameManager = vars.Mono["GameScript"];
				IntPtr levelHandler = vars.Mono["UIHandler"];
			
				//GameScript.Instance.IsPaused (+78)
				//UIHandler.Instance.CurrentWindow(+58).SubWindow(+18)
				vars.UpdateScenes = (Action) (() =>
				{
					current.GameScriptIsPaused = new DeepPointer(gameManager, 0x78).Deref<bool>(game);
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

isLoading
{
	return current.GameScriptIsPaused;
}

exit
{
	vars.TokenSource.Cancel();
}

shutdown
{
	vars.TokenSource.Cancel();
}