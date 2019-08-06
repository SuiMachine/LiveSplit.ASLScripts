state("TheThing")
{
    string12 level : 0x521A28;
    bool isNotLoading : 0x519E20;
}

split
{
    if (current.level != old.level)
    {
        if (current.level == "gui_level6")
        {
            return old.level == "gui_level4a";
        }
        else 
        {
            return true;
        }
    }
}

start
{
    return old.level == "gui_intro" && current.level == "gui_level1";
}

isLoading
{
    return !current.isNotLoading;
}