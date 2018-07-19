state("prince of persia")
{
	bool isLoading: "", 0x00DA5724, 0x50;
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
	return current.isLoading;
}

init
{
    timer.IsGameTimePaused = false;
	game.Exited += (s, e) => timer.IsGameTimePaused = true;
}