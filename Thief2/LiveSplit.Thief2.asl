state("thief2")
{
	bool isLoading: "", 0x005D4B7C, 0x7FC, 0xD8, 0x5F8, 0x70;
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
	return !current.isLoading;
}
 
gameTime
{	
} 