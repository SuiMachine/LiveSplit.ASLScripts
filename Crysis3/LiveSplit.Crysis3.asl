state("crysis3")
{
	bool isLoading: "", 0x04E7AA74, 0xE8, 0x70, 0x14, 0x64;
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