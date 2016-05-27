state("thief")
{
	bool isLoading: "", 0x005C63C0, 0x1c0, 0x74, 0x280, 0x10;
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
	return !current.isLoading;
}
 
gameTime
{	
} 