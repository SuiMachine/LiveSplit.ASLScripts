state("lanoire")
{
	bool isLoading: "", 0x0111AC64, 0x138;
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