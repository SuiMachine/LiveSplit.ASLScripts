state("avp_classic")
{	
	byte isMapLoaded : 0x4FE8FC;
	int gameState : 0x187F68;
	string20 levelName : 0x18595C;
}

split
{
	return current.levelName != old.levelName &&
		current.levelName != "fall" &&
		current.levelName != "derelict" &&
		current.levelName != "temple";
}

start
{
	return current.isMapLoaded == 1 && current.gameState == 3 && (current.levelName != "fall" ||
		current.levelName != "derelict" ||
		current.levelName != "temple");
}

isLoading
{
	return !(current.isMapLoaded == 1 && current.gameState == 3);
}
