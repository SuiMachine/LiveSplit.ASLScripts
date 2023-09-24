state("rf", "Red Faction")
{
	bool isLoading : 0x13756AC;
	string15 level : 0x0246144, 0x0;
}

state("rf_120na", "Red Faction")
{
	bool isLoading : 0x13756AC;
	string15 level : 0x0246144, 0x0;
}

state("rf2", "Red Faction 2")
{
	bool isLoading : 0x2F4408;
	string15 level : 0x31BCCC;
}

init
{
	//gameId == 0 -> RF, 1 == RF2
	vars.gameId = -1;
	vars.BinkPointer = new DeepPointer(0x0);
	vars.currentBinkMovie = false;
	vars.oldBinkMovie = false;

	var procName = game.ProcessName.ToLower();
	if(procName == "rf" || procName == "rf_120na")
	{
		vars.gameId = 0;
		vars.BinkPointer = new DeepPointer("binkw32.dll", 0x41BD8);
	}
	else if(procName == "rf2")
		vars.gameId = 1;
	
	print("Game id set to: " + vars.gameId);

	
    vars.mapList = new List<string>();
}

start
{
	if(vars.gameId == -1)
		return false;
	
	if(vars.gameId == 0)
	{
		if(current.isLoading != old.isLoading || vars.currentBinkMovie != vars.oldBinkMovie)
			return !vars.currentBinkMovie && current.level == "l1s1.rfl";
		return false;
	}
	else
		return !current.isLoading && current.level == "l00s1.rfl";
}

reset
{
	if(vars.gameId == -1)
		return false;
	
	if(vars.gameId == 0)
	{
		if(current.isLoading != old.isLoading || vars.currentBinkMovie != vars.oldBinkMovie)
			return vars.currentBinkMovie && current.level == "l1s1.rfl";
		else
			return false;
	}
	else
	{
		if(current.level == "l00s1.rfl" && old.level == "l00s1.rfl" )
			vars.mapList.Clear();
		return current.isLoading && current.level == "l00s1.rfl" && old.level != "l00s1.rfl";
	}
}

split
{
	if(vars.gameId == -1)
		return false;
	
	if(vars.gameId == 0)
	{
		if(current.level == null || current.level == "")
			return false;
		
		if(current.level != old.level)
		{
			var currentLevel = current.level.ToLower();
			var oldLevel = old.level.ToLower();
			
			print("Level changed from \"" + oldLevel + "\" to \"" + currentLevel + "\"");
			
			if	((oldLevel == "l1s3.rfl" && currentLevel == "l2s1.rfl") ||
				(oldLevel == "l2s3.rfl" && currentLevel == "l3s1.rfl") ||
				(oldLevel == "l3s4.rfl" && currentLevel == "l4s1a.rfl") ||
				(oldLevel == "l4s4.rfl" && currentLevel == "l5s1.rfl") ||
				(oldLevel == "l5s4.rfl" && currentLevel == "l6s1.rfl") ||
				(oldLevel == "l6s3.rfl" && currentLevel == "l7s1.rfl") ||
				(oldLevel == "l7s4.rfl" && currentLevel == "l8s1.rfl") ||
				(oldLevel == "l8s4.rfl" && currentLevel == "l9s1.rfl") ||
				(oldLevel == "l9s4.rfl" && currentLevel == "l10s1.rfl") ||
				(oldLevel == "l10s4.rfl" && currentLevel == "l11s1.rfl") ||
				(oldLevel == "l11s3.rfl" && currentLevel == "l12s1.rfl") ||
				(oldLevel == "l12s1.rfl" && currentLevel == "l13s1.rfl") ||
				(oldLevel == "l13s3.rfl" && currentLevel == "l14s1.rfl") ||
				(oldLevel == "l14s3.rfl" && currentLevel == "l15s1.rfl") ||
				(oldLevel == "l15s4.rfl" && currentLevel == "l17s1.rfl") ||
				(oldLevel == "l17s4.rfl" && currentLevel == "l18s1.rfl") ||
				(oldLevel == "l18s3.rfl" && currentLevel == "l19s1.rfl") ||
				(oldLevel == "l19s3.rfl" && currentLevel == "l20s1.rfl") ||
				(oldLevel == "l20s2.rfl" && currentLevel == "l20s3.rfl"))
				return true;
			else if(vars.currentBinkMovie && currentLevel ==  "l20s3.rfl")
				return true;
			else
				return false;
		}
		else
			return false;
	}	
	else if(vars.gameId == 1)
	{
		if(current.level != old.level)
		{
			if(vars.mapList.Contains(current.level))
				return false;
				
			vars.mapList.Add(current.level);
			return true;
		}
		else
			return false;
	}

}

isLoading
{
	return current.isLoading;
}

update
{
	if(vars.gameId == 0)
	{
		vars.oldBinkMovie = vars.currentBinkMovie;
		vars.currentBinkMovie = vars.BinkPointer.Deref<bool>(game);
	}
}
