state("maindll.dll")
{	
	bool isLoading : 0x72760;
	//string30 levelName : "EngineDll.dll", 0x4C066B;
}


start
{
	//return (current.isLoading && current.isLoading != old.isLoading && current.levelName == "ENTRYWAY\\WORLD.SCR");
	return false;
}
 
reset
{
	//return current.levelName == "ENTRYWAY\\WORLD.SCR" && old.levelName == "MAINMENU\\MAINMENU.SCR";
}
 
split
{
	//return (current.levelName != old.levelName && current.levelName != "MAINMENU\\MAINMENU.SCR" && current.levelName != "ENTRYWAY\\WORLD.SCR");
}

isLoading
{
	return current.isLoading;
}