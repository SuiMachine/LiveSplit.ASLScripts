state("condemned")
{
	bool isInFocus: 0x166EF0;
	int menuState: "GameClient.dll", 0x169F40;
	byte lastGameCycleLength: "", 0x16BC60, 0x330, 0x28;
}

start
{
}

reset
{
}

split
{
}

isLoading
{
	return current.lastGameCycleLength == 0 && 
		current.isInFocus &&
		current.menuState != 5;
}

init
{
    timer.IsGameTimePaused = false;
	game.Exited += (s, e) => timer.IsGameTimePaused = true;
}