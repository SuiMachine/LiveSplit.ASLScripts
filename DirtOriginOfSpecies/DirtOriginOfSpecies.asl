state("nuenginepc")
{
	bool isLoading : "", 0x27ECDD;
	string40 level : "", 0x29DF2F;
}

start
{
	return current.level == "Jail/" && !current.isLoading && old.isLoading;
}

reset
{
}

split
{
	return (current.level != old.level) && current.level != "" && old.level != ""; //&& !vars.cutsceneMaps.Contains(old.level));
}

isLoading
{
	return current.isLoading;
}

init
{
	vars.cutsceneMaps = new List<string>(){
		"MAPS\\EPISOD_1\\DRoom.map",
		"MAPS\\EPISOD_4\\e4m4_b_cs.map"
	};
}
