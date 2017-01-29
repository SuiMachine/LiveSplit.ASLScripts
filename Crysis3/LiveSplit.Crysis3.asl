state("crysis3")
{
	bool isLoading: "", 0x04CD2B60, 0x20, 0x20, 0x5c, 0x4;
}

start
{
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
