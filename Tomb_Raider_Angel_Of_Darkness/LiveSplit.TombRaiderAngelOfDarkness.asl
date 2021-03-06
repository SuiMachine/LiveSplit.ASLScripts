state("traod_p4", "P4_v52")
{	
	byte gameActionType : 0x3B6A84;
	string30 mapName : 0x460DCA;
}

state("traod_p3", "P3_v52")
{	
	byte gameActionType : 0x3A5144;
	string30 mapName : 0x44F48A;
}

state("traod_p4", "P4_v49")
{	
	byte gameActionType : 0x3B5A44;
	string30 mapName : 0x45FD8A;
}

state("traod_p3", "P3_v49")
{	
	byte gameActionType : 0x3A5104;
	string30 mapName : 0x44F44A;
}
 
start
{
	return (current.gameActionType == 0 && old.gameActionType == 1);
}
 
reset
{
	if(current.gameActionType == 1 &&  old.gameActionType == 0)
	{
		vars.mapList.Clear();
		return true;
	}
	else
		return false;
}
 
split
{
	if(current.mapName != old.mapName && current.mapName != "" && old.mapName != "" && !vars.mapList.Contains(current.mapName))
	{
		if(settings["splitOnEveryLevel"])
		{
			if(old.mapName == "PRAGUE6.GMX" && current.mapName == "FRONTEND.GMX")
				return true;		//last split
			else if(current.mapName != "FRONTEND.GMX")
			{
				vars.mapList.Add(current.mapName);
				if(current.mapName.ToLower().StartsWith("cutscene"))
				{
					if(settings["splitOnCutsceneLevels"])
						return true;
					else
						return false;
				}
				else
				{
					return true;
				}
			}
			else
				return false;
		}
		else
		{
			if(old.mapName == "PRAGUE6.GMX" && current.mapName == "FRONTEND.GMX")
				return true;		//last split
			else if(current.mapName == "CUTSCENE\\CS_2_51A.GMX" && old.mapName == "PARIS2C.GMX") 
				return true;
			else if(current.mapName == "CUTSCENE\\CS_6_16.GMX" && old.mapName == "PARIS4A.GMX") 
				return true;
			else if(current.mapName == "CUTSCENE\\CS_7_19.GMX" && old.mapName == "PARIS6.GMX") 
				return true;
			else if(current.mapName == "PRAGUE3.GMX" && old.mapName == "PRAGUE2.GMX") 
				return true;
			else if(current.mapName == "CUTSCENE\\CS_10_14.GMX" && old.mapName == "PRAGUE3.GMX") 
				return true;
			else if(current.mapName == "CUTSCENE\\CS_12_1.GMX" && old.mapName == "PRAGUE4A.GMX") 
				return true;
			else if(current.mapName == "PRAGUE6A.GMX" && old.mapName == "CUTSCENE\\CS_14_6.GMX") 
				return true;
			else
				return false;
		}
	}
	else
		return false;
}


startup
{
	settings.Add("splitOnEveryLevel", false, "Split on every level transition (except cutscenes).");
	settings.Add("splitOnCutsceneLevels", false, "Split on cutscene levels.", "splitOnEveryLevel");
	settings.Add("pauseOnSaveGameLoad", false, "Pause No-loads timer on Save game load (refer to run rules!)");
}

init
{
	string tempFileName = modules.First().ModuleName.ToLower();
	int tempVer = modules.First().FileVersionInfo.FilePrivatePart;
	vars.mapList = new List<string>();
	
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
	//6: Cutscene / FMV / conversation
	//7: Idle
	//8: Unknown
	//9: Game over menu
	//10: Save game or Menu load
	//11: Unknown (No strings)
	//12: Unknown (No strings, might be wrong pointer case)
}