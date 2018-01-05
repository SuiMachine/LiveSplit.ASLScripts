state("traod_p4", "P4_v52")
{	
	byte gameActionType : 0x3B6A84;
	string20 mapName : 0x460DCA;
}

state("traod_p3", "P3_v52")
{	
	byte gameActionType : 0x3A5144;
	string20 mapName : 0x44F48A;
}

state("traod_p4", "P4_v49")
{	
	byte gameActionType : 0x3B5A44;
	string20 mapName : 0x45FD8A;
}

state("traod_p3", "P3_v49")
{	
	byte gameActionType : 0x3A5104;
	string20 mapName : 0x44F44A;
}
 
start
{
	return (current.gameActionType == 0 && old.gameActionType == 1);
}
 
reset
{
	return (current.gameActionType == 1 &&  old.gameActionType == 0);
}
 
split
{
	return current.level != old.level && current.level != "FRONTEND.GMX" && old.level != "FRONTEND.GMX";
}


startup
{
	settings.Add("pauseOnSaveGameLoad", false, "Pause No-loads timer on Save game load (refer to run rules!)");
}

init
{
	string tempFileName = modules.First().ModuleName.ToLower();
	int tempVer = modules.First().FileVersionInfo.FilePrivatePart;
	
	if(tempVer == 49)
	{
		if(tempFileName == "traod_p4.exe")
		{
			version = "P4_v49";
		}
		else
		{
			version = "P3_v49";
		}
	}
	else
	{
		if(tempFileName == "traod_p4.exe")
		{
			version = "P4_v52";
		}
		else
		{
			version = "P3_v52";
		}
	}
}
 
isLoading
{
	return (current.gameActionType == 1 ||
		(current.gameActionType == 2 && settings["pauseOnSaveGameLoad"]) ||
		current.gameActionType == 3 ||
		current.gameActionType == 4 ||
		current.gameActionType == 10);
		
	//So basically it is based on switch jump, where:
	//0: Normal
	//1: NewGame
	//2: LoadGame
	//3: LevelLoad (Next level load?)
	//4: Exit?
	//5: Unknown (Level select? Or console map load?)
	//6: Unknown (Something with cutscene)
	//7: Idle
	//8: Unknown
	//9: Pre-rendered cutscene?
	//10: Save game or Menu load
	//11: Unknown (No strings)
	//12: Unknown (No strings, might be wrong pointer case)
}