state("TheThing")
{
    string9 intro : 0x521A28;
    string3 level : 0x521A31;
    bool isNotLoading : 0x519E20;
}

init
{
}

update
{
}

split
{
	return current.level != old.level;
}

start
{
    return current.intro == "gui_level" && old.intro != "gui_level";
}

isLoading
{
    return !current.isNotLoading;
}