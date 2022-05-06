state("comm2")
{	
	bool isLoadingHidden : 0x815BDC, 0xE4;
	byte gameState : 0x7CBAD4, 0x2C; 
}

//Game states:
//1 - normal
//4 - game menu
//9 - mission completed screen
//10 - cinematic?

isLoading
{
	return !current.isLoadingHidden || current.gameState == 9;
}