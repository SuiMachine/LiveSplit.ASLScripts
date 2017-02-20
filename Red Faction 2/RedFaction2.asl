state("rf2")
{
	bool isLoading : 0x2F4408;
	string15 level : 0x31BCCC;
}

init
{
    vars.mapList = new List<string>();
}

start
{
	return !current.isLoading && current.level == "l00s1.rfl";
}

reset
{
	if(current.level == "l00s1.rfl" && old.level == "l00s1.rfl" )
		vars.mapList.Clear();
	return current.isLoading && current.level == "l00s1.rfl" && old.level != "l00s1.rfl";
}

split
{
	if(current.level != old.level)
	{
		if(vars.mapList.Contains(current.level))
			return false;
			
		vars.mapList.Add(current.level);
		return true;
	}
	else
		return false;
}

isLoading
{
	return current.isLoading;
}

