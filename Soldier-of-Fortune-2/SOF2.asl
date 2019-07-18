state("SoF2")
{
	int cGamex86Tick : "cgamex86.dll", 0x000B8418;		//This gets set to -1 at load finish and incremented with each game tick, one worry is that module gets unloaded and loaded constantly into memory and LiveSplit may loose it. Let's hope this does not happen.
	string20 level : 0x7820DD;
}

start
{
	return current.level == "pra1.bsp" && current.cGamex86Tick != 0;
}

reset
{
	return current.level == "pra1.bsp" && old.level != "pra1.bsp" && current.cGamex86Tick == 0;
}

split
{
	return (old.level != "pra1.bsp") && current.level != old.level;
}

isLoading
{
	return current.cGamex86Tick == 0;
}
