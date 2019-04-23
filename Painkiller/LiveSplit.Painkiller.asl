state("painkiller")
{	
	bool pLoadingScreen : "Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x9C;
	int pTick : "Engine.dll", 0x3E9D2C;	
	//To explain:
	//"Engine.dll", 0x4FEBE68 -> *PCFSystem
	//"Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4 -> *LoadingScreen (identical case for other games, just different offsets)
	//"Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x88-> Bool value telling whatever loading is happening
	//"Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x88 + 0xC-> Float value for the progress indicator (aka % of completion - but we don't use it)
}

state("overdose")
{	
	bool pLoadingScreen : "OverdoseEngine.dll", 0x4FEB330, 0x70, 0x5D6BD4, 0x90;
	int pTick : "OverdoseEngine.dll", 0x3E7CB0;
}

state("resurrection")
{	
	bool pLoadingScreen : "ResurrectionEngine.dll", 0x4EE2900, 0x70, 0x5D6BD4, 0x90;
	int pTick : "ResurrectionEngine.dll", 0x2DEFE4;
}

state("redemption")
{	
	bool pLoadingScreen : "RedemptionEngine.dll", 0x4EE64B8, 0x70, 0x5D6BD4, 0x90;
	int pTick : "RedemptionEngine.dll", 0x2DFE84;
}

state("recurringevil")
{	
	bool pLoadingScreen : "REEngine.dll", 0x4EE60B8, 0x70, 0x5D6BD4, 0x90;
	int pTick : "REEngine.dll", 0x02DFA84;
}

init
{
	vars.oldTick = -1;
}

isLoading
{
	if(current.pLoadingScreen)
	{
		vars.oldTick = current.pTick;
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
