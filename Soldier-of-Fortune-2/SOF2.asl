state("SoF2")
{
	string20 level : 0x7820DD;
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
	return current.level == "pra1.bsp" && vars.cGamexTick != 0;
}

reset
{
	return current.level == "pra1.bsp" && old.level != "pra1.bsp" && vars.cGamexTick == 0;
}

split
{
	return (old.level != "pra1.bsp") && current.level != old.level;
}

isLoading
{
	return vars.cGamexTick == 0;
}
