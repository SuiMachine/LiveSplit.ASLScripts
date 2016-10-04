state("wolf2")
{
	bool isLoading: "gamex86.dll", 0x875C6C;
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