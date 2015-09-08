state("emuhawk")
{
	uint GameTimer: "octoshock.dll", 0x3A562C;
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
	return false;
}
 
gameTime
{	
	return TimeSpan.FromSeconds(current.GameTimer/4096f);
} 