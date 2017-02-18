state("saboteur", "GOG")
{
	bool isLoading: "", 0x010A9B14, 0xBBD0;
}

state("saboteur", "Origin")
{
	bool isLoading: "", 0x010964F4, 0xBBD0;
}

init
{
	if(modules.First().ModuleMemorySize == 31395840)
	{
		version = "Origin";
	}
	else
	{
		version = "GOG";
	}
	//print(version);
	
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
 
gameTime
{	
} 