state("hell")
{
	bool isLoading : "", 0x26BBB64;
	string40 level : "", 0x64ACC0;
}

start
{
	if(current.level == "MAPS\\EPISOD_1\\e1m1.map" && !current.isLoading && old.isLoading)
	{
		vars.completedMaps.Clear();
		vars.completedMaps.Add(current.level);
		return true;
	}
	else
		return false;
}

reset
{
}

split
{
	if(string.IsNullOrEmpty(current.level))
		return false;

	if(current.level != old.level && !vars.cutsceneMaps.Contains(old.level) && !vars.completedMaps.Contains(current.level))
	{
		vars.completedMaps.Add(current.level);
		return true;
	}
	else
		return false;
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

	vars.completedMaps = new HashSet<string>();
}
