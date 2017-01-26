state("crysis64", "64_DX9")
{
	bool isLoading: "CryRenderD3D9.dll", 0x6694E5;
}

state("crysis64", "64_DX10")
{
	bool isLoading: "CryRenderD3D10.dll", 0x630055;
}

init
{
	foreach(ProcessModuleWow64Safe module in modules)
    {
		Debug.WriteLine("Module check...");
		if(module.ModuleName.ToLower() == "cryrenderd3d9.dll")
		{
			version = "64_DX9";
			Debug.WriteLine("Chosen DX9");
			break;
		}
        else if(module.ModuleName.ToLower() == "cryrenderd3d10.dll")
		{
			version = "64_DX10";
			Debug.WriteLine("Chosen DX9");
			break;
		}
	}
	vars.isLoading = false;
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
	return vars.isLoading;
}

update
{
	vars.isLoading = current.isLoading;
}