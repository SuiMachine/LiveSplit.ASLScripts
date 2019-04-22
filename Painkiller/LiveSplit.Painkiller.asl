state("painkiller")
{	
	bool pLoadingScreen : "Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x9C;
	//To explain:
	//"Engine.dll", 0x4FEBE68 -> *PCFSystem
	//"Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4 -> *LoadingScreen (identical case for other games, just different offsets)
	//"Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x88-> Bool value telling whatever loading is happening
	//"Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x88 + 0xC-> Float value for the progress indicator (aka % of completion - but we don't use it)
}

state("overdose")
{	
	bool pLoadingScreen : "OverdoseEngine.dll", 0x4FEB330, 0x70, 0x5D6BD4, 0x90;
}

state("resurrection")
{	
	bool pLoadingScreen : "ResurrectionEngine.dll", 0x4EE2900, 0x70, 0x5D6BD4, 0x90;
}

state("redemption")
{	
	bool pLoadingScreen : "RedemptionEngine.dll", 0x4EE64B8, 0x70, 0x5D6BD4, 0x90;
}

state("recurringevil")
{	
	bool pLoadingScreen : "REEngine.dll", 0x4EE60B8, 0x70, 0x5D6BD4, 0x90;
}


split
{
}

start
{
}

init
{
	vars.oldTick = -1;
	var gName = game.ProcessName.ToLower();
	if(gName == "resurrection")
	{
		vars.tickWatcher = new MemoryWatcher<int>(new DeepPointer("ResurrectionEngine.dll", 0x2DEFE4));
		vars.UsesTickDiff = true;
	}
	else if(gName == "overdose")
	{
		vars.tickWatcher = new MemoryWatcher<int>(new DeepPointer("OverdoseEngine.dll", 0x3E7CB0));
		vars.UsesTickDiff = true;
	}
	else if(gName == "recurringevil")
	{
		vars.tickWatcher = new MemoryWatcher<int>(new DeepPointer("REEngine.dll", 0x02DFA84));
		vars.UsesTickDiff = true;
	}
	else
		vars.UsesTickDiff = false;
}

update
{
	if(vars.UsesTickDiff)
		vars.tickWatcher.Update(game);
}

isLoading
{
	if(vars.UsesTickDiff)
	{
		if(current.pLoadingScreen)
		{
			vars.oldTick = vars.tickWatcher.Current;
			return true;
		}
		else
		{
			if(vars.oldTick == -1)
			{
				return false;
			}
			else
			{
				if(vars.oldTick != vars.tickWatcher.Current)
				{
					//print("NOT loading because diff tick (old tick: " + vars.oldTick.ToString() + ", newTick" + vars.tickWatcher.Current.ToString() + ")");
					vars.oldTick = -1;
					return false;
				}
				else
				{
					//print("Loading because oldTick == currentTick: " + vars.oldTick.ToString());

					return true;
				}
			}
		}
	}
	else
		return current.pLoadingScreen;
}
