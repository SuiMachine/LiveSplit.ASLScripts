state("avp_classic")
{	
	int levelTime : 0x4FE7C8;
	string20 levelName : 0x18595C;
}

gameTime
{	
	if(current.levelTime > 5000)
	{
		vars.gTime += TimeSpan.FromSeconds((current.levelTime - old.levelTime) / 65536d);
	}
	return vars.gTime;
} 

split
{
	return current.levelName != old.levelName &&
		current.levelName != "fall" &&
		current.levelName != "derelict" &&
		current.levelName != "temple";
}

start
{
	return current.levelTime < 5000 && 	(current.levelName != "fall" ||
		current.levelName != "derelict" ||
		current.levelName != "temple");
}

isLoading
{
	return true;
}

init
{
	vars.gTime = new TimeSpan();
	timer.OnReset += (s, e) => 
	{
		vars.gTime = TimeSpan.Zero;
	};
}
