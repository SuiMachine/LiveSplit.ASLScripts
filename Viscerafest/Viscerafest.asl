// This code is partially based on what Ero's Unity ASL generator spews out
// It wasn't however generated by it, cause the version of Unity is not supported.

state("viscerafest")
{
	int gameState : "mono-2.0-bdwgc.dll", 0x497DC8, 0x38, 0xF08, 0x0, 0x60, 0x0;	//inside GameManager
	bool loadingQuickSave : "mono-2.0-bdwgc.dll", 0x497DC8, 0x38, 0xF08, 0x0, 0x60, 0x45;
}

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

	settings.Add("sceneSplits", true, "Split after finishing a scene:");
	foreach (string scene in SplitScenes)
		settings.Add(scene, true, scene, "sceneSplits");

	vars.TimerStart = (EventHandler) ((s, e) => vars.CompletedSplits.Clear());
	timer.OnStart += vars.TimerStart;
}

init
{
	vars.CompletedSplits = new List<string>();

	var UnityPlayerModule = modules.FirstOrDefault(m => m.ModuleName == "UnityPlayer.dll");
	var UnityPlayerScanner = new SignatureScanner(game, UnityPlayerModule.BaseAddress, UnityPlayerModule.ModuleMemorySize);
	
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

	var SceneManagerBindings = IntPtr.Zero;

	int scanAttempts = 0;
	while (scanAttempts++ < 50)
		if ((SceneManagerBindings = UnityPlayerScanner.Scan(SceneManagerBindingsSig)) != IntPtr.Zero) break;

	if (!(vars.SigFound = SceneManagerBindings != IntPtr.Zero))
	{
		print("Not found: " + SceneManagerBindings.ToString("X8"));
		return;
	}
	
	print("Mov instruction of g_RuntimeSceneManager: " + SceneManagerBindings.ToString("X8"));
	var g_RuntimeSceneManager = IntPtr.Add(SceneManagerBindings + 7, game.ReadValue<int>(SceneManagerBindings + 3));
	print("RuntimeSceneManager at: " + g_RuntimeSceneManager.ToString("X8"));

	Func<string, string> PathToName = (path) =>
	{
		if (String.IsNullOrEmpty(path) || !path.StartsWith("Assets/")) return null;
		else return System.Text.RegularExpressions.Regex.Matches(path, @".+/(.+).unity")[0].Groups[1].Value;
	};
	
	vars.UpdateScenes = (Action) (() =>
	{
		current.ThisScene = PathToName(new DeepPointer(g_RuntimeSceneManager, 0x48, 0x10, 0x0).DerefString(game, 73)) ?? old.ThisScene;
		current.NextScene = PathToName(new DeepPointer(g_RuntimeSceneManager, 0x28, 0x0, 0x10, 0x0).DerefString(game, 73)) ?? old.NextScene;
	});
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