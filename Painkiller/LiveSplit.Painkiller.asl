state("painkiller", "Steam")
{	
	//To find addresses, reverse LoadingScreen::Render and get GEngine address for that
	//"Engine.dll", 0x4FEBE68 -> *PCFSystem
	
	//Then X-ref back to World::Init. There you can find a first offset for GEngine and a bool value
	//Do keep in mind that for example IDA says  *((_DWORD *)GEngine + 0x3C), but it's a DWORD, so it's 4 times 3C, so 0xF0 (now we base and offset)
	//"Engine.dll", 0x4FEBE68, 0xF0
	
	//Now find LoadingScreen::Progress(v23, 1) in that function and get pointer for a bool value from that
	//"Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4 -> *LoadingScreen (identical case for other games, just different offsets)
	//"Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x88-> Bool value telling whatever loading is happening
	
	//And then if you want to be bothered there is:
	//"Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x88 + 0xC-> Float value for the progress indicator (aka % of completion - but we don't use it)
	bool pLoadingScreen : "Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x9C;
	
	//To get a tick, find an extern function PCFSystem::TickEngine
	//In it, somewhere after middle you'll find a call to a function SystemDriver::GetCurrentTimeMS
	//It returns the time in MS and above has an int variable that is getting incremeneted with each tick and is set to 0 (below one of the calls to SystemDriver::GetCurrentTimeMS)
	int pTick : "Engine.dll", 0x3E9D2C;	
	
	//Name of a level you get by solving out pointer in World::Init
	string25 pLevelName : "Engine.dll", 0x4FEBE68, 0xE8, 0x01888, 0x0;
}

state("painkiller", "Retail-PL_v1_64")
{	
	bool pLoadingScreen : "Engine.dll", 0x4FE6E78, 0xF0, 0x5D6BD4, 0x88;
	int pTick : "Engine.dll", 0x3E4D38;
	string25 pLevelName : "Engine.dll", 0x4FE6E78, 0xE8, 0x01888, 0x0;
}

state("overdose")
{	
	bool pLoadingScreen : "OverdoseEngine.dll", 0x4FEB330, 0x70, 0x5D6BD4, 0x90;
	int pTick : "OverdoseEngine.dll", 0x3E7CB0;
	string25 pLevelName : "OverdoseEngine.dll", 0x4FEB330, 0x64, 0x01888, 0x0;
}

state("resurrection")
{	
	bool pLoadingScreen : "ResurrectionEngine.dll", 0x4EE2900, 0x70, 0x5D6BD4, 0x90;
	int pTick : "ResurrectionEngine.dll", 0x2DEFE4;
	string25 pLevelName : "ResurrectionEngine.dll", 0x4EE2900, 0x64, 0x01888, 0x0;
}

state("redemption")
{	
	bool pLoadingScreen : "RedemptionEngine.dll", 0x4EE64B8, 0x70, 0x5D6BD4, 0x90;
	int pTick : "RedemptionEngine.dll", 0x2DFE84;
	string25 pLevelName : "RedemptionEngine.dll", 0x4EE64B8, 0x64, 0x01888, 0x0;
}

state("recurringevil")
{	
	bool pLoadingScreen : "REEngine.dll", 0x4EE60B8, 0x70, 0x5D6BD4, 0x90;
	int pTick : "REEngine.dll", 0x02DFA84;
	string25 pLevelName : "REEngine.dll", 0x4EE60B8, 0x64, 0x01888, 0x0;
}

startup
{
	vars.StartUpLevels = new List<string>();
	vars.LevelsLoaded = new List<string>();
	vars.IsRunStart = false;
	
	//Event handler to clear levels loaded on reset (cause player may do it manually)
	timer.OnReset += (s, val) => { 
		//print("[NOLOADS] Clearing list of loaded levels.");
		vars.LevelsLoaded.Clear(); 
	};
	
	//This is a stupid workaround, as you can not define event handler that uses values from State Descriptors, so we just do it in update instead based on the flag
	timer.OnStart += (s, args) => { 
		vars.IsRunStart = true;
	};
}

update
{
	if(vars.IsRunStart)
	{
		if(current.pLevelName != "")
		{
			print("[NOLOADS] Adding a startup level to the list of loaded levels " + current.pLevelName);
			vars.LevelsLoaded.Add(current.pLevelName);
		}
		vars.IsRunStart = false;
	}
}


init
{
	//Pause timer if game quits or crashes...
	game.Exited += (s, e) => timer.IsGameTimePaused = true;

	vars.oldTick = -1;
	vars.OldLevelName = "";
	var ProcessNameLowered = game.ProcessName.ToLower();
	
	if(ProcessNameLowered == "painkiller")
	{
		var tempModule = modules.FirstOrDefault(x =>  x.ModuleName.ToLower() == "engine.dll");
		
		if(tempModule != null)
		{
			switch(tempModule.ModuleMemorySize)
			{
				case 84168704:
					version = "Steam";
					break;
				case 84144128:
					version = "Retail-PL_v1_64";
					break;
				default:
					print("Unknown engine.dll size: " + tempModule.ModuleMemorySize);
					break;
			}
		}
		
		vars.StartUpLevels = new List<string>() {
			"1x04_cemetery",
			"C6L1_Orphanage"
		};
	}
	else if(ProcessNameLowered == "overdose")
		vars.StartUpLevels = new List<string>() { "c8l03_cataclysm" };
	else if(ProcessNameLowered == "resurrection")
		vars.StartUpLevels = new List<string>() { "c9l01_cathedral" };	
	else if(ProcessNameLowered == "redemption")
		vars.StartUpLevels = new List<string>() { "DM_Cursed" };	
	else if(ProcessNameLowered == "recurringevil")
		vars.StartUpLevels = new List<string>() { "C10L1_Unfortunate_Abbey" };
}

start
{
	if(!current.pLoadingScreen && current.pLevelName != "" && current.pLoadingScreen != old.pLoadingScreen  )
	{
		vars.OldLevelName = current.pLevelName;
		return vars.StartUpLevels.Contains(current.pLevelName);
	}
	else
		return false;
}

reset
{
}

split
{
	if(current.pLevelName != null && current.pLevelName != "")
	{
		if(current.pLevelName != vars.OldLevelName)
		{
			print("[NOLOADS] Map changed from \"" + vars.OldLevelName + "\" to \"" + current.pLevelName +"\"");
			vars.OldLevelName = current.pLevelName;
			if(!vars.LevelsLoaded.Contains(current.pLevelName))
			{
				print("[NOLOADS] Adding \"" + current.pLevelName + "\" to the list of loaded levels.");
				vars.LevelsLoaded.Add(current.pLevelName);
				return true;
			}
			else
				return false;
		}
		return false;
	}
	return false;
}

isLoading
{
	if(current.pLoadingScreen)
	{
		vars.oldTick = current.pTick;
		return true;
	}
	else if(current.pLevelName == "")
		return true;
	else
	{
		if(vars.oldTick == -1)
		{
			return false;
		}
		else
		{
			if(vars.oldTick != current.pTick)
			{
				vars.oldTick = -1;
				return false;
			}
			else
			{
				return true;
			}
		}
	}
}
