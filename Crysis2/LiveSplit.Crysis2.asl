state("crysis2")
{
	bool isLoading: "Crysis2.exe", 0x1346304;
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