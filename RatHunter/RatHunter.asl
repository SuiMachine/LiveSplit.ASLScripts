state("rathunter")
{
	bool isLoading : "", 0x0028B1C0, 0x88;
	//string40 level : "", 0x64ACC0;
}

start
{
	return false;
	//return current.level == "MAPS\\EPISOD_1\\e1m1.map" && !current.isLoading && old.isLoading;
}

reset
{
}

split
{
	return false;
	//return (current.level != old.level && !vars.cutsceneMaps.Contains(old.level));
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
