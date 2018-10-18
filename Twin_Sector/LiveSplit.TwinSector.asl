state("twinsector_steam")
{	
	byte menuType : 0x10D7E5EC;
}

split
{
}

start
{
}

isLoading
{
	return current.menuType != 0;
}
