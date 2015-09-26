state("silent hill 4")
{
	uint GameTimer: "Silent Hill 4.exe", 0x00BD5C50;
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
	return TimeSpan.FromSeconds(current.GameTimer/30f);
} 