state("GAME")
{
	//01_01_0.dds -> 00, 01, 0
	//01_02b_
	string12 levelPic : "Game.dll", 0x992B4;
}

init
{
    vars.isActive = false;
	vars.oldIsactive = false;
	vars.currentLevel = "";
	vars.oldLevel = "";
}

update
{
	vars.oldLevel = vars.currentLevel;
	vars.oldIsactive = vars.isActive;
	if(current.levelPic.Contains("_"))
	{
		var levelStr = current.levelPic.Split('.')[0];
		var split = levelStr.Split('_');
		vars.currentLevel = split[0] + '_' + split[1];
		vars.isActive = split[2] == "0" ? false : true;
	}
}

start
{
	return vars.currentLevel == "01_01" && vars.isActive && !vars.oldIsactive;
}

reset
{
	return vars.currentLevel == "01_01" && !vars.isActive && vars.oldIsactive;
}

split
{
	return vars.currentLevel != vars.oldLevel && vars.currentLevel != "01_01";
}

isLoading
{
	return !vars.isActive;
}