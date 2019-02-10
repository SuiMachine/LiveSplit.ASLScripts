state("skout")
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
	vars.originalStartLoadAddy = 0x00528F6C;
	vars.originalEndLoadAddy = 0x00529011;

	vars.injectedIsLoadingPtr = game.AllocateMemory(sizeof(int));
	vars.isLoadingPtrBytes = BitConverter.GetBytes((uint)vars.injectedIsLoadingPtr);
	
	// injected isLoadingDetour
	var contentOfInjectionCode = new List<byte>()
	{
		0xC7, 0x05																		//mov [injectedIsLoadingPtr],1
	};
	contentOfInjectionCode.AddRange(vars.isLoadingPtrBytes);
	contentOfInjectionCode.AddRange(new byte[] { 1, 0, 0, 0 });	
	contentOfInjectionCode.AddRange(new byte[] {0x8b, 0x0D, 0x8C, 0x25, 0x71, 0x00 });		//mov     ecx, dword_71258C
	contentOfInjectionCode.AddRange(new byte[] {0xE9, 0xFF, 0xFF, 0xFF, 0xFF });   		//jmp PLACEHOLDER
	
	//2nd injection
    var secondSegmentPtr = contentOfInjectionCode.Count;
	contentOfInjectionCode.AddRange(new byte[] { 0xC7, 0x05 });							//mov [injectedIsLoadingPtr],0
	contentOfInjectionCode.AddRange(vars.isLoadingPtrBytes);
	contentOfInjectionCode.AddRange(new byte[] { 0, 0, 0, 0 });	
	contentOfInjectionCode.AddRange(new byte[] {0xA1, 0x88, 0x25, 0x71, 0x00 });		//mov     eax, dword_712588
	contentOfInjectionCode.AddRange(new byte[] {0xE9, 0xFF, 0xFF, 0xFF, 0xFF });   		//jmp PLACEHOLDER
	
	vars.injectedStartLoadHookPtr = game.AllocateMemory(contentOfInjectionCode.Count);
	game.Suspend();

	try
	{
		//Write hook content into memory
		vars.oInitPtr = game.WriteBytes((IntPtr)vars.injectedStartLoadHookPtr, contentOfInjectionCode.ToArray());
		
		//Replace placeholder jump and hook start load
		game.WriteJumpInstruction((IntPtr)vars.injectedStartLoadHookPtr + secondSegmentPtr - 5, (IntPtr)vars.originalStartLoadAddy + 6);
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

isLoading
{
	return game.ReadValue<bool>((IntPtr)vars.injectedIsLoadingPtr);
}