state("EternalWar-HQ")
{
	string10 map : "", 0x459B1FD;
	float igt : "", 0x2202C3C, 0x11a0;
}

start
{
	return current.map == "start.bsp" && current.igt > 0 && current.igt != old.igt;
}

reset
{	
	return current.igt == 0 && current.map == "start.bsp";
}

split
{
	return current.map != old.map && current.map != "start.bsp" && current.map != "";
}

isLoading
{
	return current.igt == old.igt;
}