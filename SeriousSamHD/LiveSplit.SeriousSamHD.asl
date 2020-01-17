state("samhd")
{	
}

startup
{
	vars.FreeMemory = (Action<Process>)(p =>
    {
        p.FreeMemory((IntPtr)vars.injectedIsLoadingPtr);
        p.FreeMemory((IntPtr)vars.contentOfInjectionCode);
    });
	
	vars.CheckInitiation = (Func<Process, IntPtr, bool>)((p, ptr) =>
    {
        if (ptr == IntPtr.Zero)
            return false;

        byte[] bytes;
        if (!p.ReadBytes(ptr, 3, out bytes))
            return false;

        var expectedBytes = new byte[] { 0xE8, 0x9C, 0xF7, 0x32, 0x00 };
        if (!bytes.SequenceEqual(expectedBytes))
            return false;

        return true;
    });
}

init
{
	vars.originalStartLoadAddy = 0x007C5CFF;
	vars.originalEndLoadAddy = 0x007C5D4A;

	vars.injectedIsLoadingPtr = game.AllocateMemory(sizeof(int));
	vars.isLoadingPtrBytes = BitConverter.GetBytes((uint)vars.injectedIsLoadingPtr);
	
	/*
    if (!vars.CheckInitiation(game, (IntPtr)0x0048E50F))
        throw new Exception("Incorrect initiation!");*/

	
	// injected isLoadingDetour
	var contentOfInjectionCode = new List<byte>()
	{
		0xC7, 0x05																		//mov [injectedIsLoadingPtr],1
	};
	contentOfInjectionCode.AddRange(vars.isLoadingPtrBytes);
	contentOfInjectionCode.AddRange(new byte[] { 1, 0, 0, 0 });	
	contentOfInjectionCode.AddRange(new byte[] {0x68, 0xD8, 0x57, 0xD1, 0x00 });		//push Started loading world %1
	contentOfInjectionCode.AddRange(new byte[] {0xE9, 0xFF, 0xFF, 0xFF, 0xFF });   		//jmp PLACEHOLDER
	
	//2nd injection
    var secondSegmentPtr = contentOfInjectionCode.Count;
	contentOfInjectionCode.AddRange(new byte[] { 0xC7, 0x05 });							//mov [injectedIsLoadingPtr],0
	contentOfInjectionCode.AddRange(vars.isLoadingPtrBytes);
	contentOfInjectionCode.AddRange(new byte[] { 0, 0, 0, 0 });	
	contentOfInjectionCode.AddRange(new byte[] {0x68, 0xBC, 0x57, 0xD1, 0x00 });		//push Started loading world %1
	contentOfInjectionCode.AddRange(new byte[] {0xE9, 0xFF, 0xFF, 0xFF, 0xFF });   		//jmp PLACEHOLDER
	
	vars.injectedStartLoadHookPtr = game.AllocateMemory(contentOfInjectionCode.Count);
	game.Suspend();

	try
	{
		//Write hook content into memory
		vars.oInitPtr = game.WriteBytes((IntPtr)vars.injectedStartLoadHookPtr, contentOfInjectionCode.ToArray());
		
		//Replace placeholder jump and hook start load
		game.WriteJumpInstruction((IntPtr)vars.injectedStartLoadHookPtr + secondSegmentPtr - 5, (IntPtr)vars.originalStartLoadAddy + 5);
		game.WriteJumpInstruction((IntPtr)vars.originalStartLoadAddy, (IntPtr)vars.injectedStartLoadHookPtr);
		
		//Replace placeholder jump and hook end load
		game.WriteJumpInstruction((IntPtr)vars.injectedStartLoadHookPtr + contentOfInjectionCode.Count - 5, (IntPtr)vars.originalEndLoadAddy + 5);	
		game.WriteJumpInstruction((IntPtr)vars.originalEndLoadAddy, (IntPtr)vars.injectedStartLoadHookPtr + secondSegmentPtr);
		
	}
	catch
	{
		vars.FreeMemory(game);
		throw;
	}
	finally
	{
		game.Resume();
	}	
}

update
{
}

split
{
}

start
{
}

isLoading
{
	return game.ReadValue<bool>((IntPtr)vars.injectedIsLoadingPtr);
}