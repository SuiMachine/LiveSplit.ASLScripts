state("sh3")
{
	float GameTimer: "sh3.exe", 0x6CE66F4;
}
 
start
{
	current.AccumulatedGameTime = 0;
	
	return old.GameTimer > 0 && current.GameTimer == 0;
}
 
reset
{
	current.AccumulatedGameTime = 0;
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
	if (current.GameTimer < old.GameTimer && current.GameTimer != 0)
		current.AccumulatedGameTime += (old.GameTimer - current.GameTimer);
	
	return TimeSpan.FromSeconds(current.GameTimer + current.AccumulatedGameTime);
} 