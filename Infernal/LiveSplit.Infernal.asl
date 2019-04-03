state("game")
{
	byte isPaused: 0x6FE398;
	byte loadSaveCase: 0x728800;
}

init
{
	vars.IsActualLoadingFlag = false;
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

update
{
	if( current.loadSaveCase != old.loadSaveCase && (current.loadSaveCase > 0 || current.isPaused != 0))
		vars.IsActualLoadingFlag = true;
	else if ( current.isPaused == 0)
		vars.IsActualLoadingFlag = false;
}
 
isLoading
{
	return vars.IsActualLoadingFlag;
}
