state("painkiller")
{	
	bool pLoadingScreen : "Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x9C;
	//To explain:
	//"Engine.dll", 0x4FEBE68 -> *PCFSystem
	//"Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4 -> *LoadingScreen (identical case for other games, just different offsets)
	//"Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x88-> Bool value telling whatever loading is happening
	//"Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x88 + 0xC-> Float value for the progress indicator (aka % of completion - but we don't use it)
	//Issues known - the LoadingScreen object is disposed of quite a bit of time before the world simulation starts (this is especially true for Overdose and Resurrection)

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

isLoading
{
	return current.pLoadingScreen;
}
