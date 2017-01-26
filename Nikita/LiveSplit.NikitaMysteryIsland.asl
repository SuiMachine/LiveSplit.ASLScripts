state("nikita")
{
	bool isLoading: "ChromeEngine2.dll", 0x4E08B1;
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