state("deadspace3")
{
	int loading: "deadspace3.exe", 0xEAB630;
}

isLoading
{
	return current.loading != 0;
}