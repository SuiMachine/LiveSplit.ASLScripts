state("sh3")
{
	float GameTimer: "sh3.exe", 0x6CE66F4;
}
 
start
{	
	return old.GameTimer > 0 && current.GameTimer == 0;
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
	return TimeSpan.FromSeconds(current.GameTimer);
} 