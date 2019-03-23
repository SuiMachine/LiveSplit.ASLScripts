state("painkiller")
{	
	int pLoadingScreen : "Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x9C;
	//To explain:
	//"Engine.dll", 0x4FEBE68 -> *GEngine
	//"Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x88 -> *LoadingScreen
	//"Engine.dll", 0x4FEBE68, 0xF0, 0x5D6BD4, 0x88 + 0x14 -> Some value used to check whatever the loading is still on
}

state("overdose")
{	
	int pLoadingScreen : "OverdoseEngine.dll", 0x4FEB330, 0x70, 0x5D6BD4, 0x98;
}

split
{
}

start
{
}

isLoading
{
	return current.pLoadingScreen != 0x0;
}
