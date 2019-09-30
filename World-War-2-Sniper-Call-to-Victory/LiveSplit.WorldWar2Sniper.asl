state("lithtech")
{	
	bool isGameTimePaused : 0x1C12D0, 0x194;
	//int gameTime : 0x1C12D0, 0x504;					//This is to minimize the impact of menu loading or other freeze (although it will pause the timer incorrectly if the FPS drops below 10... I think)
}

split
{
}

start
{
}

isLoading
{
	return current.isGameTimePaused; //|| (current.gameTime - old.gameTime) == 0;
}
