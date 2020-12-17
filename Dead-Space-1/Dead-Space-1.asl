state("Dead Space")
{
	int gameState: 0xB442B8;
	string10 chapterName: 0x00B648DC, 0x9C;
}

start
{
	return current.gameState != old.gameState && current.gameState == 0 && current.chapterName == "CH01_flt\\";
}

split
{
	return current.chapterName != old.chapterName && current.chapterName != "frontend\\" && old.chapterName != "frontend\\";
}

isLoading
{
	return current.gameState != 0 && current.gameState != 4;
}
