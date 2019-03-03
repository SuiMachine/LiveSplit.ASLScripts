state("WorldWarZero")
{	
	byte gameActionType : 0x2B3F3C;
	byte levelID : 0x271680;
	//LevelID can be converted to name by solving pointer
	//WorldWarZero.exe +27168C + (1C*(LevelID-1))
	//but we don't need that, since a simple byte tells us everything we need to know and is way faster to read
}
 
start
{
	return (current.gameActionType == 2 && (old.gameActionType == 1 || old.gameActionType == 15));
}
 
reset
{
	if(current.gameActionType == 2 && (old.gameActionType == 1 || old.gameActionType == 15) && current.levelID == 0)
	{
		return true;
	}
	else
		return false;
}

split
{
	return current.levelID > old.levelID;
}

isLoading
{
	return (current.gameActionType != 2 && current.gameActionType != 11 && current.gameActionType != 8 && current.gameActionType != 10);
		
	//1 = Loading Map
	//2 = IsGame
	//7 = Loading?
	//8 = Main Menu
	//9 = Unknown? Movie or Pause?
	//10 = Something to do with in-game menu
	//11 = Menu
	//12 = Load save (with map reload)
	//13 = Load Main Menu
	//14 = PerformInLevelLoad
	//15 = Restart Level (buggy?)
}