state("lithtech")
{	
	bool isGameTimePaused : 0x1C12D0, 0x194;
}

split
{
}

start
{
}

isLoading
{
	return current.isGameTimePaused;
}
