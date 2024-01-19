//This was originally written by Rythin
state("RedFactionArmageddon_DX11", "Steam")
{
	bool isGameplay:			0xC0DBD0;   //1 on loads and fmvs leading to a load
	int pseudoLoadScreenState:	0xC0DB80;   //0 - just loading (unless loading is 0^^), 1 when fading from black, 2 when showing FMV, 3 when fading to black
	int map:					0x98DE28;   //0-27 on the according levels, -1 during load
	string25 fmv_name:			0x996BA8;   //the filename of the fmv currently playing
}

state("RedFactionArmageddon", "Steam")
{
	bool isGameplay:			0xC1C650;
	int pseudoLoadScreenState:	0xC1C600;
	int map:					0x99DE28;
	string25 fmv_name:			0x9A6BA8;
}

state("RedFactionArmageddon_DX11", "GOG")
{
	bool isGameplay:			0xC1AF50;
	int pseudoLoadScreenState:	0xC1AF00;
	int map:					0x99BE28;
	string25 fmv_name:			0x9A4BF8;
}

state("RedFactionArmageddon", "GOG")
{
	bool isGameplay:			0xC2AA50;
	int pseudoLoadScreenState:	0xC2AA00;
	int map:					0x9ACE28;
	string25 fmv_name:			0x9B5BF8;
}

startup
{
	//Settings
	var splitNames = new string[]
	{
		"Armageddon",
		"Terraformer",
		"Dig site",
		"We're not alone",
		"Outbreak",
		"Road to Bastion",
		"Bastion defences",
		"Water supplies",
		"Ice Mines",
		"Infection",
		"On the run",
		"The Red Faction",
		"Relay stations",
		"Heavy Metal",
		"The temple",
		"Hale",
		"Must go faster",
		"Marauder defences",
		"Older enemies",
		"Air support",
		"The road less travelled",
		"Knock knock",
		"The lair",
		"Queen",
		"Armageddon v2",
		"Reversal of fortune",
		"End game"
	};
	
	settings.Add("map_change_splits", true, "Map change splits");
	for(int i=0; i < splitNames.Length; i++)
	{
		settings.Add("map_change_number_" + i.ToString(), true, splitNames[i] + " (" + (i+1).ToString() + ")", "map_change_splits");
	}
	settings.Add("ending_split", true, "Split at the end");

	
	//Variables
	vars.Dbg = (Action<dynamic>) ((output) => print("[Mono ASL] " + output));
	vars.StartFMVs = new HashSet<string>() { "m01_cs_00.bik" };
	vars.CompletedMaps = new bool[256];
	vars.CompletedMaps[0] = true;
	
	vars.TimerStart = (EventHandler) ((s, e) => 
	{
		for(int i=0; i < vars.CompletedMaps.Length; i++)
		{
			vars.CompletedMaps[i] = false;
		}
		
		vars.last_fmv = "";
		vars.CompletedMaps[0] = true;
	});
	timer.OnStart += vars.TimerStart;
	
	vars.last_fmv = "";
}

init
{
	switch (modules.First().ModuleMemorySize)
	{
		case 51249152:
		case 49659904:
			version = "GOG";
			break;
		case 51187712:
		case 49602560: 
		default:
			version = "Steam";
			break;
	}
}

update
{
	if (current.pseudoLoadScreenState == 2)
	{
		vars.last_fmv = current.fmv_name;
	}
}

reset
{
	if (current.map != old.map || !current.isGameplay != old.isGameplay || current.pseudoLoadScreenState != old.pseudoLoadScreenState)
	{
		if(!current.isGameplay && current.pseudoLoadScreenState == 2 && vars.StartFMVs.Contains(current.fmv_name))
		{
			return true;
		}
	}
	
	return false;
}

start
{
	if (current.map != old.map || current.isGameplay != old.isGameplay || current.pseudoLoadScreenState != old.pseudoLoadScreenState)
	{
		if(!old.isGameplay && current.isGameplay && (current.map == 0 || current.map == 1))
		{
			vars.Dbg("Starting");
			return true;
		}
	}
	else
		return false;
}

split
{	
	if (current.map != old.map)
	{
		if(current.map > 0 && !vars.CompletedMaps[current.map])
		{
			if(current.map >= 256)
			{
				vars.Dbg("Out of range?");
			}
			else
			{
				vars.CompletedMaps[current.map] = true;
				vars.Dbg("Split case 1. Map ID: " + current.map);
				var splitSetting = settings["map_change_number_" + (current.map - 1)];
				return splitSetting;
			}
		}
	}
    
	if (current.pseudoLoadScreenState > 0 && !string.IsNullOrWhiteSpace(vars.last_fmv) && (vars.last_fmv.ToLower() == "m17_mo_theend_cs_19.bik" || vars.last_fmv.ToLower() == "dlc04_m04_end.bik"))
	{
		vars.Dbg("Split Ending");
		return settings["ending_split"];
	}
	
	return false;
}

isLoading
{
	return (!current.isGameplay && (current.pseudoLoadScreenState == 0 || current.pseudoLoadScreenState == 1 || current.pseudoLoadScreenState == 3));
}

exit
{
	timer.IsGameTimePaused = true;
}

shutdown
{
	timer.OnStart -= vars.TimerStart;
}