state("crysis64")
{
	int levelLoadId : 0x7C9180, 0x4d8, 0xA0;	
	int levelLoadIterator : 0x7C9180, 0x4d8, 0xB0;	
	string20 levelName : 0x7C9180, 0x4d8, 0x88, 0x0;
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
	if(current.levelLoadIterator == 0)
		vars.isLoading = true;
	else if(current.levelLoadId != old.levelLoadId)
		vars.isLoading = false;
}