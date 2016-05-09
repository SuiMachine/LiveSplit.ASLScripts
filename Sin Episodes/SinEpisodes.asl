state("SinEpisodes")
{
	bool isLoading : "engine.dll", 0x3E4444;
	string20 level : "engine.dll", 0x349629;
}

start
{
	return current.level == "se1_docks01.bsp" && !current.isLoading;
}

reset
{
	return current.level == "se1_docks01.bsp" && !current.isLoading && old.isLoading;
}

split
{
	return ((current.level == "SE1_U4Lab01.bsp" && old.level == "se1_docks04.bsp") ||
	(current.level == "SE1_U4Lab03.bsp" && old.level == "SE1_U4Lab02.bsp") ||
	(current.level == "se1_pit02.bsp" && old.level == "se1_pit01.bsp") ||
	(current.level == "se1_highrise03.bsp" && old.level == "se1_highrise02.bsp") ||
	(current.level == "se1_finale01.bsp" && old.level == "se1_highrise03.bsp") ||
	(current.level == "se1_finale02.bsp" && old.level == "se1_finale01.bsp"));
}

isLoading
{
	return current.isLoading;
}
