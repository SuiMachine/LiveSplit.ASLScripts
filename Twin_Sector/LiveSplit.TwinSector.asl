state("twinsector_steam")
{	
	byte menuType: 0x10D7E5EC;
}

startup
{
	vars.FreeMemory = (Action<Process>)(p =>
    {
        p.FreeMemory((IntPtr)vars.injectedIsLoadingPtr);
        p.FreeMemory((IntPtr)vars.allocation);
        p.FreeMemory((IntPtr)vars.allocation2);
    });
}

init
{
	vars.sigScanLoadStart = new SigScanTarget("C7 45 90 0F 00 00 00 " +  //mov [ebp-70],0000000F
    "33 C0 " +      //xor eax,eax
    "89 45 8C" +    //mov [ebp-74],eax
    "68"            //push TwinSector_Steam.exe+4C4730 (part only)
    );
	
	vars.module = game.MainModule;
	vars.scanner = new SignatureScanner(game, vars.module.BaseAddress, vars.module.ModuleMemorySize);
	vars.functionAddress = vars.scanner.Scan(vars.sigScanLoadStart);
	if (vars.functionAddress == IntPtr.Zero)
		throw new Exception("Sigscan returned Null Pointer!");
	vars.loadEndAddress = vars.functionAddress + 0xCF;

	vars.injectedIsLoadingPtr = game.AllocateMemory(sizeof(int));
	vars.isLoadingPtrBytes = BitConverter.GetBytes((uint)vars.injectedIsLoadingPtr);

	var contentOfStartLoadHook = new List<byte>
	{
		0xC7, 0x45, 0x90, 0x0F, 0x00, 0x00, 0x00, //mov [ebp-70],0000000F
		0xC7, 0x05                                //mov [injectedIsLoadingPtr],1
	};

	contentOfStartLoadHook.AddRange(vars.isLoadingPtrBytes);
	contentOfStartLoadHook.AddRange(new byte[] { 1, 0, 0, 0 });
	contentOfStartLoadHook.AddRange(new byte[] { 0xE9, 255, 255, 255, 255 });
	
	var contentOfEndLoadHook = new List<byte>
	{
		0xC7, 0x45, 0xFC, 0x00, 0x00, 0x00, 0x00,//mov [ebp-0x04],0
		0xC7, 0x05                              //mov [injectedIsLoadingPtr],0
	};
	contentOfEndLoadHook.AddRange(vars.isLoadingPtrBytes);
	contentOfEndLoadHook.AddRange(new byte[] { 0, 0, 0, 0 });
	contentOfEndLoadHook.AddRange(new byte[] { 0xE9, 255, 255, 255, 255 });

	vars.allocation = game.AllocateMemory(contentOfStartLoadHook.Count);
	vars.allocation2 = game.AllocateMemory(contentOfEndLoadHook.Count);
	game.Suspend();

	try
	{
		//Write hook content into memory
		vars.oInitPtr = game.WriteBytes((IntPtr)vars.allocation, contentOfStartLoadHook.ToArray());
		game.WriteJumpInstruction((IntPtr)vars.allocation + contentOfStartLoadHook.Count - 5, (IntPtr)vars.functionAddress + 7);
		
		//Hook original function
		game.WriteBytes((IntPtr)vars.functionAddress, new byte[] { 0xE9, 0xFF, 0xFF, 0xFF, 0xFF, 0x90, 0x90 });
		print("Function address: " + vars.allocation.ToString("X"));

		game.WriteJumpInstruction((IntPtr)vars.functionAddress, (IntPtr)vars.allocation);
		
		//Write end load into memory
		vars.oEndPtr = game.WriteBytes((IntPtr)vars.allocation2, contentOfEndLoadHook.ToArray());
		game.WriteJumpInstruction((IntPtr)vars.allocation2 + contentOfEndLoadHook.Count - 5, (IntPtr)vars.loadEndAddress + 7);
		
		//Hook end load fragment of loading
		game.WriteBytes((IntPtr)vars.loadEndAddress, new byte[] { 0xE9, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90 });
		game.WriteJumpInstruction((IntPtr)vars.loadEndAddress, (IntPtr)vars.allocation2);
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