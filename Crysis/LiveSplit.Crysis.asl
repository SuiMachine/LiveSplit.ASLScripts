state("crysis")
{
	float loadTimeIsh : "CryAction.dll", 0x2DA22C, 0x4AC, 0x50;	//Honestly no idea what that is, but it seems to be float
	int levelLoadId : "CryAction.dll", 0x2DA22C, 0x4AC, 0x5C;	
	string20 levelName : "CryAction.dll", 0x2DA22C, 0x4AC, 0x48, 0x0;
}

state("crysis64")
{
	float loadTimeIsh : "CryGame.dll", 0x3F6D20, 0x10, 0x4d8, 0x94;	//Honestly no idea what that is, but it seems to be float
	int levelLoadId : "CryGame.dll", 0x3F6D20, 0x10, 0x4d8, 0xA0;	
	string20 levelName : "CryGame.dll", 0x3F6D20, 0x10, 0x4d8, 0x88, 0x0;
}

init
{
	vars.isLoading = false;
}
 
start
{
	return current.levelLoadId != old.levelLoadId;
}
 
reset
{
}
 
split
{
	return current.levelName != old.levelName;
}
 
isLoading
{
	return vars.isLoading;
}

update
{
	if(current.loadTimeIsh == 0.0f)
		vars.isLoading = true;
	else if(current.levelLoadId != old.levelLoadId)
		vars.isLoading = false;
}