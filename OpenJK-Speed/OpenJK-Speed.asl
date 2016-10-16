state("openjk_sp.x86")
{
	bool isActive : 0x407AA4;
	string30 level : 0x40E10C;
}

init
{
    vars.mapList = new List<string>();
}

start
{
	return current.isActive && current.level == "maps/yavin1b.bsp";
}

reset
{
	if(current.level == "maps/yavin1b.bsp" && old.level == "maps/yavin1b.bsp" )
		vars.mapList.Clear();
	return !current.isActive && current.level == "maps/yavin1b.bsp" && old.level != "maps/yavin1b.bsp";
}

split
{
	if(current.level != old.level)
	{
		if(current.level.StartsWith("maps/academy") || current.level == "")
			return false;
		else
		{
			if(vars.mapList.Contains(current.level))
				return false;
				
			vars.mapList.Add(current.level);
			return true;
		}
	}
	else
		return false;
}

isLoading
{
	return !current.isActive;
}

