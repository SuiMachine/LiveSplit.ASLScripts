state("comm2")
{	
	bool isLoadingHidden : 0x815BDC, 0xE4;
}

isLoading
{
	return !current.isLoadingHidden;
}