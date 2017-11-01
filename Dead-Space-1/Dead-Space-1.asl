state("Dead Space")
{
	int loading: "Dead Space.exe", 0xD6F328;
}

isLoading
{
	return current.loading != 0;
}
