state("rage")
{
	bool isShowingSpiningThing : "", 0x1152615;
	string40 levelName : "", 0x11C7E41;
}

state("rage64")
{
	bool isShowingSpiningThing : "", 0x29B7249;
	string40 levelName : "", 0x29BFCA2;
}

start
{
	return false;
	//return current.level == "MAPS\\EPISOD_1\\e1m1.map" && !current.isLoading && old.isLoading;
}

reset
{
}

split
{
	return (current.levelName != old.levelName && current.levelName != "" && old.levelName != "");
}

isLoading
{
	return current.isShowingSpiningThing;
}
