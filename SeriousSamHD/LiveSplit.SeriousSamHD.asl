state("samhd")
{
}

startup
{	
	vars.TimerStart = (EventHandler) ((s, e) => vars.CompletedSplits.Clear());
	timer.OnStart += vars.TimerStart;
}

init
{
	vars.SigFound = false;
	vars.TokenSource = new CancellationTokenSource();
	vars.CompletedSplits = new List<string>();
	current.Level = "";
	current.isLoading = false;
	vars.UpdateScenes = (Action) (() => {});
	
	vars.SigThread = new Thread(() =>
	{
		print("Starting signature thread.");
		
		var isLoadingBaseAddy = IntPtr.Zero;
		
		//IsLoading base
		var isLoadingBaseSig = new SigScanTarget(0, "8B 0D ?? ?? ?? ?? 03 C3 A3 ?? ?? ?? ?? 89 7C");
		//SceneManagerBindingsSig.OnFound = (p, s, ptr) => IntPtr.Add(ptr + 4, p.ReadValue<int>(ptr));
		
		var Token = vars.TokenSource.Token;
		while (!Token.IsCancellationRequested)
		{
			var GameModules = game.ModulesWow64Safe();
			
			var isLoadingScanner = new SignatureScanner(game, game.MainModule.BaseAddress, game.MainModule.ModuleMemorySize);
			
			if (isLoadingBaseAddy == IntPtr.Zero && (isLoadingBaseAddy = isLoadingScanner.Scan(isLoadingBaseSig)) != IntPtr.Zero)
			{
				//print("Mov instruction of SceneManagerBindings: " + SceneManagerBindings.ToString("X8"));
				print("Found SceneManagerBinding: 0x" + isLoadingBaseAddy.ToString("X16"));
			}
			
			vars.SigFound = isLoadingBaseAddy != IntPtr.Zero;

			if (!vars.SigFound)
			{
				Thread.Sleep(2000);
				if(isLoadingBaseAddy == IntPtr.Zero)
					print("isLoading is null");
			}
			else
			{
		
				vars.UpdateScenes = (Action) (() =>
				{
					current.isLoading = new DeepPointer(isLoadingBaseAddy, 0x9FCE20, 0x0, 0x0).Deref<bool>(game);
					//current.Level = new DeepPointer(SceneManagerBindings, 0x48, 0x10, 0x0).DerefString(game, 73) ?? old.ThisScene;
				});
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

start
{
}

split
{
}


reset
{
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