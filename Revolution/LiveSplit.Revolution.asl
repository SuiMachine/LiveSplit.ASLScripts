state("maindll.dll", "v1.0-Retail")
{	
	bool isLoading : 0x72760;
	//string30 levelName : "EngineDll.dll", 0x4C066B;
}

state("maindll.dll", "v1.1-NoCD")
{	
	bool isLoading : "INTERFACEDLL.DLL", 0x5EA80;
	//string30 levelName : "EngineDll.dll", 0x4C066B;
}

init
{
	int moduleSize = modules.First().ModuleMemorySize;
	if(moduleSize == 479232)
		version = "v1.1-NoCD";
	else
		version = "v1.0-Retail";
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