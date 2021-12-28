state("SamHD") {}

startup
{
	settings.Add("0_01_Hatshepsut", false, "Split after finishing Hatshepsut");
}

init
{
	var P_Module = game.MainModule;
	var P_Scanner = new SignatureScanner(game, P_Module.BaseAddress, P_Module.ModuleMemorySize);

	IntPtr LoadField = IntPtr.Zero, LevelField = IntPtr.Zero;
	var LoadTrg = new SigScanTarget(2, "8B 35 ?? ?? ?? ?? 8D 64 24 00");
	var LevelTrg = new SigScanTarget(1, "A3 ?? ?? ?? ?? FF D2");

	foreach (var trg in new[] { LoadTrg, LevelTrg })
		trg.OnFound = (p, s, ptr) => p.ReadPointer(ptr);

	int scanAttempts = 0;
	while (scanAttempts++ < 20)
	{
		LoadField = P_Scanner.Scan(LoadTrg);
		LevelField = P_Scanner.Scan(LevelTrg);

		if (vars.SigsFound = new[] { LoadField, LevelField }.All(a => a != IntPtr.Zero)) break;
	}

	if (!vars.SigsFound) return;

	vars.Loading = new MemoryWatcher<bool>(new DeepPointer(LoadField, 0x0, 0x0));
	vars.Level = new StringWatcher(new DeepPointer(LevelField, 0x20, 0x1C, 0x0), 32);
}

update
{
	if (!vars.SigsFound) return false;

	vars.Loading.Update(game);
	vars.Level.Update(game);
}

start
{
	return vars.Loading.Old && !vars.Loading.Current && vars.Level.Current == "0_01_Hatshepsut";
}

split
{
	return vars.Level.Old != vars.Level.Current && settings[vars.Level.Old];
}

isLoading
{
	return vars.Loading.Current;
}