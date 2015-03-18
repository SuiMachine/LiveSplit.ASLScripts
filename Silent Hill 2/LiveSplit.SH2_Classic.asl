state("sh2pc")
{
	float GameTimer: "sh2pc.exe", 0x19BFB94;
}
 
start
{
	return old.GameTimer == 0 && current.GameTimer > 0;		//Autostart if only a current time is higher than 0 (can't be done using old.GamerTimer == 0, since it's already 0 in menu).
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