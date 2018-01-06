state("avp_dx11")
{	
	bool isActive : 0x5FFED8;
	bool oldIsLoadingPtr : 0x000FB610, 0x60;
	string40 mapName : 0x5D4B5D;
}


start
{
	if(settings["useOldIsLoading"])
	{
		if(!current.oldIsLoadingPtr && old.oldIsLoadingPtr && (current.mapName == "Lab\\A01_Lab.pc" || current.mapName == "Colony\\M01_Colony.pc" || current.mapName == "P00_Tutorial\\P00_PredTutorial.pc"))
		{
			print("[NOLOADS] Start signal using oldPointerRead.");
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		if(current.isActive && !old.isActive && (current.mapName == "Lab\\A01_Lab.pc" || current.mapName == "Colony\\M01_Colony.pc" || current.mapName == "P00_Tutorial\\P00_PredTutorial.pc"))
		{
			print("[NOLOADS] Start signal.");
			return true;
		}
		else
		{
			return false;
		}
	}
}
 
reset
{
	if(current.mapName != old.mapName && (current.mapName == "Lab\\A01_Lab.pc" || current.mapName == "Colony\\M01_Colony.pc" || current.mapName == "P00_Tutorial\\P00_PredTutorial.pc"))
	{
		vars.mapList.Clear();
		vars.mapList.Add("Lab\\A01_Lab.pc");
		vars.mapList.Add("Colony\\M01_Colony.pc");
		vars.mapList.Add("P00_Tutorial\\P00_PredTutorial.pc");
		vars.mapList.Add("Demo_SPS.pc");
		print("[NOLOADS] Reset signal.");
		return true;		
	}
	else
		return false;
}
 
split
{
	if(current.mapName != old.mapName && current.mapName != "" && old.mapName != "" && !vars.mapList.Contains(current.mapName))
	{
		return true;
	}
	else
	{
		return false;
	}
}


startup
{
	settings.Add("useOldIsLoading", false, "Use old isLoading pointer.");
}

init
{
	vars.mapList = new List<string>();
}

update
{
	if(current.mapName != old.mapName)
	{
		print("[NOLOADS] Current map change: " + old.mapName + " -> " + current.mapName);
	}
}
 
isLoading
{
	if(!settings["useOldIsLoading"])
		return !current.isActive;
	else
		return current.oldIsLoadingPtr;
}