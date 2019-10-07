state("gta2", "v9.6")
{
    bool ingame: 0x267DA8;
	bool pause: 0x266531;
    uint requiredScore: 0x2EF7E0, 0x310;
    uint mission: 0x2EF7E0, 0x328, 0x0;
    uint token: 0x2764A4;
    uint frenzy: 0x2EF7E0, 0x338, 0x0;
    uint score: 0x26D9C0, 0x188;
	uint cycle: 0x271E44, 0x0;
}
state("gta2", "v9.6f")
{
    bool ingame: 0x1DE068;
	bool pause: 0x1DCB58;
    uint requiredScore: 0x2644BC, 0x310;
    uint mission: 0x2644BC, 0x328, 0x0;
    uint token: 0x1EC5E4;
    uint frenzy: 0x2644BC, 0x338, 0x0;
    uint score: 0x1E3CC4, 0x188;
	uint cycle: 0x1E8108, 0x0;
}
state("gta2", "v11.44")
{
    bool ingame: 0x1EE068;
	bool pause: 0x1ECB58;
	bool missionScript: 0x2744BC;
	uint requiredScore: 0x2744BC, 0x310;
    uint mission: 0x2744BC, 0x328, 0x0;
    uint token: 0x1FC5E4;
    uint frenzy: 0x2744BC, 0x338, 0x0;
    uint score: 0x1F3CC4, 0x188;
	uint cycle: 0x1F8108, 0x0;
}

startup 
{
	refreshRate = 45;
	
	/// Mission Settings
	settings.Add("Mission", true, "Missions");
	settings.Add("Complete_All", true, "Complete all Missions before exit", "Mission");
	settings.SetToolTip("Complete_All", "Only split on exit if all Missions in one area are completed.");
	settings.Add("Downtown", true, "Downtown", "Mission");
	settings.SetToolTip("Downtown", "Select at which completed mission count in the Downtown area you want to split.");
	settings.Add("Residential", true, "Residential", "Mission");
	settings.SetToolTip("Residential", "Select at which completed mission count in the Residential area you want to split.");
	settings.Add("Industrial", true, "Industrial", "Mission");
	settings.SetToolTip("Industrial", "Select at which completed mission count in the Industrial area you want to split.");
	// Add checkbox for every mission in each area
	for (int i = 1; i <= 22; i++)
	{
		settings.Add("DT_"+i, true, "Mission "+i, "Downtown");
		settings.Add("RS_"+i, true, "Mission "+i, "Residential");
		settings.Add("ID_"+i, true, "Mission "+i, "Industrial");
	} 
  
	/// Token and Frenzy Settings
	settings.Add("Token", false, "Tokens");
	settings.SetToolTip("Token", "Split after each collected token.");
	settings.Add("Frenzy", false, "Frenzies");
	settings.SetToolTip("Frenzy", "Split after each completed kill frenzy.");

	/// Ingame to menu transition Settings
	settings.Add("Transition", false, "Split on any ingame to menu transition");
	settings.SetToolTip("Transition", "Split on any ingame to menu transitions ignoring required score or missions.");
	
	vars.frames = 0;
	vars.startFrames = 0;
	vars.diffFrames = 0;
	vars.splitTime = TimeSpan.Zero;
	vars.startTime = TimeSpan.Zero;
	vars.igt = TimeSpan.Zero;
	vars.avgFps = 0;
}

init
{   
	/// Check game version
	if ((int)modules.First().BaseAddress == 0x400000)
    {
        if ((int)modules.First().ModuleMemorySize == 0x278000)
			version = "v9.6f";
		else if ((int)modules.First().ModuleMemorySize == 0x303000)
			version = "v9.6";
    }
    else if ((int)modules.First().BaseAddress == 0x3F0000)
    {
        version = "v11.44";
    }
}

update
{ 
	if (version == "") return false;
	
	if (current.ingame)
	{
	    //if (!old.ingame || ((current.pause != old.pause) && old.pause)) {vars.startTime = timer.CurrentTime.RealTime;}
		
	    if (current.cycle == 1) 
		{
		  vars.startTime = timer.CurrentTime.RealTime;
		  vars.startFrames = 0;
		}
		else if ((current.pause != old.pause) && old.pause)
		{
		  vars.startTime = timer.CurrentTime.RealTime;
		}
		
		if (current.pause) {vars.startFrames = current.cycle-1;}
		
		vars.requiredScore = current.requiredScore;
		vars.score = current.score;
		
		vars.frames = current.cycle-1;
		vars.splitTime = timer.CurrentTime.RealTime - vars.startTime;
		vars.igt = TimeSpan.FromSeconds(vars.frames/30.3);
		vars.diffFrames = vars.frames-vars.startFrames;
		if (!current.pause && (vars.diffFrames > 0)) {vars.avgFps = (vars.diffFrames)/vars.splitTime.TotalSeconds;}		
	}
	else
	{		
		vars.runActive = false;
		vars.oldRequiredScore = 0;
	}	
}

start 
{
	// Start timer on a new game
	if (current.ingame && vars.score == 0 && vars.requiredScore != 0 && !vars.runActive)
	{   
		vars.missionCount = 0U;
		vars.runActive = true;
		vars.startTime = TimeSpan.Zero;
		vars.startFrames = 0;
		return true; 
	}
}

split 
{
	// Prevents instant split when reloading a save file with bigger counter values (missions, tokens etc.) than before
	if (vars.oldRequiredScore != current.requiredScore && current.ingame) 
	{
		vars.oldRequiredScore = current.requiredScore;
		return false;
	}
	
	// Split on any ingame to menu transition or if target score is reached 
	if (!current.ingame && current.ingame != old.ingame)  
	{
		if (settings["Transition"])
		{
			return true;
		}
		else if (vars.score > vars.requiredScore)
		{
			if (!(settings["Mission"] && settings["Complete_All"] && old.mission < 22))
				return true;
		}
	}
	// Split on selected missions
	else if (settings["Mission"] && current.mission > old.mission)
	{		
		vars.missionCount = current.mission;
		// Downtown missions
		if (settings["Downtown"] && vars.requiredScore == 1000000 && settings["DT_"+vars.missionCount])
		{  
			return true;
		}
		// Residential missions:  Mission counter bugs out at or after the "Final Job!" and can end up with 23/22 or 24/22
		if (vars.missionCount > 22)	vars.missionCount = 22U;
		if (!(current.mission == 22 || current.mission > 24) && settings["Residential"] && vars.requiredScore == 3000000 && settings["RS_"+vars.missionCount])
		{
			return true;
		}
		// Industrial missions
		if (settings["Industrial"] && vars.requiredScore == 5000000 && settings["ID_"+vars.missionCount])
		{
			return true;
		} 
	}
	else if (settings["Token"] && current.token - old.token == 1) 
	{
		return true;
	}
	else if (settings["Frenzy"] && current.frenzy - old.frenzy == 1) 
	{
		return true;
	}
}

reset 
{
	// Reset on every new game start
	if (settings.ResetEnabled && current.ingame && !vars.runActive && vars.score == 0 && vars.requiredScore != 0)
	{ 
	    vars.startTime = TimeSpan.Zero;
		vars.startFrames = 0;
		return true;
	} 
	// Prevents timer to restart automatically on manual reset if previously menu was visited with the timer running
	else if (!settings.ResetEnabled) 
		vars.runActive = true;
}