state("cryostasis")
{
	string60 mapName: 0x17B24B3;
	bool isLoading: 0x1B80715;
}

start
{
	return (current.mapName != "" && current.mapName == "bios20\\bios20.map" && current.isLoading != old.isLoading);
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
