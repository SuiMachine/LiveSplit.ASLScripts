state("deadspace2")
{
	int loading: "deadspace2.exe", 0x1C18B5C;
}

isLoading
{
	return current.loading != 0;
}
