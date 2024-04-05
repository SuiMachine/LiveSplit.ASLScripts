//This is based on pure guesses, cause debugger crashes the game
state("ffcrossroads")
{
	bool LoadingScreen : 0x167C8CC;
	bool FMV_Playing: "bink2w64.dll", 0x57B2C; //Yes, I know - you don't have to skip FMVs, but come on - the skip button is so broken
	bool LevelReloadScreen : 0x19E2D88;
}

init
{
	//vars.previousKurwaState = false;
}

isLoading
{
	return current.LoadingScreen || current.FMV_Playing || current.LevelReloadScreen;
}

update
{
	//if(timer.IsGameTimePaused != vars.previousKurwaState)
	//{
		//print("[" + timer.CurrentTime.RealTime.ToString() + "] State change " + timer.IsGameTimePaused.ToString());
	//}
	//vars.previousKurwaState = timer.IsGameTimePaused;
}