state("psiops")
{
	bool isLoading: 0x68B4D4;
	string26 levelName: 0x68BA98;
}

init
{
	vars.IgnoreLevels = new List<string>()
	{
		"extra_level00"
	};
}

start
{
	return !current.isLoading && old.isLoading && current.levelName == "map_level00_A1";
}
 
reset
{
}
 
split
{
	if(old.levelName != current.levelName)
	{
		if(vars.IgnoreLevels.Contains(old.levelName) || current.levelName == "extra_level97" || old.levelName == "extra_level97")
			return false;
		else
			return true;
	}
	else
		return false;
}
 
isLoading
{
	return current.isLoading;
}
