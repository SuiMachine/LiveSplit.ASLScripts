state("trl")
{
	bool isLoading: "", 0xCC0A54;
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