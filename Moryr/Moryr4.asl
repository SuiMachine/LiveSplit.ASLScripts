state("game")
{
    bool isLoading : "GameClient.dll", 0x210D82;
	string30 levelName : 0x1C412D;
}

isLoading
{
	return current.isLoading;
}

start
{
	return current.levelName == "level_1_1[ulica].World00p" && !current.isLoading && old.isLoading;
}

split
{
}

update
{

}

init
{
}
