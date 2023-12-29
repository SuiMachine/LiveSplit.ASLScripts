//This was originally written by Rythin

state("RedFactionArmageddon_DX11", "Steam")
{
	bool loading:      0x1CEA928;  //1 on loads and fmvs leading to a load
	int map:           0x98DE28;   //0-27 on the according levels, -1 during load
	bool fmv:          0x121CDB8;  //1 in fmv cutscenes
	string25 fmv_name: 0x996BA8;   //the filename of the fmv currently playing
}

state("RedFactionArmageddon", "Steam")
{
	bool loading:      0xC1C653;
	int map:           0x99DE28;
	bool fmv:          0x122B82B;
	string25 fmv_name: 0x9A6BA8;
}

state("RedFactionArmageddon_DX11", "GOG")
{
	bool loading:      0x1CF7D28;
	int map:           0x99BE28;
	bool fmv:          0x9A4C8C;
	string25 fmv_name: 0x9A4BF8;
}

state("RedFactionArmageddon", "GOG")
{
	bool loading:      0x1D07828;
	int map:           0x9ACE28;
	bool fmv:          0x9B5C8C;
	string25 fmv_name: 0x9B5BF8;
}

startup
{
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
	vars.sw = new Stopwatch();
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
	if (current.fmv && !old.fmv)
	{
		vars.sw.Restart();
	}
	
	if (vars.sw.ElapsedMilliseconds > 900)
	{
		vars.last_fmv = current.fmv_name;
		vars.sw.Reset();
	}
}

reset
{
	if (current.map != old.map || current.loading != old.loading || current.fmv != old.fmv)
	{
		if(current.loading && vars.StartFMVs.Contains(current.fmv_name))
		{
			return true;
		}
	}
	
	return false;
}

start
{
	if (current.map != old.map || current.loading != old.loading || current.fmv != old.fmv)
	{
		if(!current.loading && !current.fmv && (current.map == 0 || current.map == 1))
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
				vars.Dbg("Split case 1");
				return true;
			}
		}
	}
    
	if (!current.fmv && old.fmv && !string.IsNullOrWhiteSpace(vars.last_fmv) && (vars.last_fmv.ToLower() == "m17_mo_theend_cs_19.bik" || vars.last_fmv.ToLower() == "dlc04_m04_end.bik"))
	{
		vars.Dbg("Split 2");
		return true;
	}
	
	return false;
}

isLoading
{
	return (current.loading && !current.fmv || current.map == -1);
}

exit
{
	timer.IsGameTimePaused = true;
}

shutdown
{
	timer.OnStart -= vars.TimerStart;
}