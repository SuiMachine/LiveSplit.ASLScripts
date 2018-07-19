state("game")
{
    bool isLoading : "GameClient.dll", 0x2331E2;
	string30 levelName : 0x1C6195;
}

isLoading
{
	return current.isLoading;
}

start
{
	return current.levelName == "level_1.World00p" && !current.isLoading && old.isLoading;
}

split
{
	/*
	if(current.levelName != "")
		vars.currentMapName = current.levelName;

	if(vars.currentMapName != vars.oldMapName)
	{
		vars.oldMapName = vars.currentMapName;
		return true;
	}
	else
	{
		vars.oldMapName = vars.currentMapName;
		return false;
	}*/
}

update
{

}

init
{
	/*
	string oldMapName = "";
	string currentMapName = "";*/
}
