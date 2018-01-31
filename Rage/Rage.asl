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
	return !current.isShowingSpiningThing && old.isShowingSpiningThing && current.levelName.EndsWith("wasteland1");
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
