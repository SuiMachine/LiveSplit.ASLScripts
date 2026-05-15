state("SoF2")
{
	string20 level : 0x7820DD;
	float timeScale : 0x3FA514; //timescale is 1000 when skipping cutscene
}

init
{
	vars.cGamexTick = 0;
}

update
{
	vars.cGamexTick = game.ReadValue<int>(new IntPtr(0x300B8418)); //This gets set to -1 at load finish and incremented with each game tick, one worry is that module gets unloaded and loaded constantly into memory and LiveSplit generally misses it, so it's absolute address instead.
}

start
{
	if(settings["startOnCutscene"])
		return current.level == "pra2.bsp" && current.timeScale == 1000 && old.timeScale == 1;
	else
		return current.level == "pra2.bsp" && vars.cGamexTick != 0;
}

reset
{
	return current.level == "pra2.bsp" && old.level != "pra2.bsp" && vars.cGamexTick == 0;
}

split
{
	return (old.level != "pra1.bsp" && current.level != "pra1.bsp") && current.level != old.level;
}

isLoading
{
	return vars.cGamexTick == 0 || (settings["pauseOnCutscene"] && current.timeScale == 1000 );
}

startup
{
	settings.Add("pauseOnCutscene", true, "Pause on cutscenes skipping.");
	settings.Add("startOnCutscene", true, "Start on cutscene skip instead of level load.");
}
