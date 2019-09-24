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