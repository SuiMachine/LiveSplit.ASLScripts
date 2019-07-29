state("psiops")
{
	bool isLoading: 0x68B4D4;
	string8 levelName: 0x68AF2C;
}

init
{
	vars.IgnoreLevels = new List<string>()
	{
		"97" //menu
	};
}

start
{
	return !current.isLoading && old.isLoading && current.levelName == "00";
}
 
reset
{
}
 
split
{
	if(old.levelName != current.levelName)
	{
		print("[NOLOADS] " + old.levelName + " => " + current.levelName);
		if(vars.IgnoreLevels.Contains(old.levelName) || current.levelName == "97")
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
