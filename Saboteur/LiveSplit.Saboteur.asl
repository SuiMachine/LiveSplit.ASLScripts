state("saboteur")
{
	bool isLoading: "", 0x010964F4, 0xBBD0;
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