state("ua")
{	
}

startup
{
	vars.FreeMemory = (Action<Process>)(p =>
    {
        p.FreeMemory((IntPtr)vars.injectedPtrForLevelSystemPtr);
        p.FreeMemory((IntPtr)vars.allocation);
    });
}

init
{
	vars.IsCorrectProcess = false;
	vars.LevelSystemUpdateHkStart = IntPtr.Zero;
	
	if(game.MainWindowTitle == "Underworld Ascendant")
	{
		print("[NOLOADS] Valid process name and window title");
		vars.sigScanTarget = new SigScanTarget("55 " +
			"48 8B EC " +
			"48 83 EC 30 " +
			"48 89 75 F8 " +
			"48 8B F1 " +
			"48 8B 46 10 " +
			"48 85 C0 " +
			"?? ?? " +
			"48 8B 46 10 " +
			"48 8B C8 " +
			"48 89 45 F0 " +
			"FF 50 18 " +
			"48 8B 45 F0 " +
			"48 8B 75 F8");
			
		
		vars.injectedPtrForLevelSystemPtr = game.AllocateMemory(IntPtr.Size);
		vars.injectedPtrForLevelSystemBytes = BitConverter.GetBytes((ulong)vars.injectedPtrForLevelSystemPtr);
		vars.functionAddress = IntPtr.Zero;
		
		var contentOfAHook = new List<byte>
		{
			0x48, 0x89, 0x75, 0xF8,		//mov [rbp-08],rsi
			0x48, 0x8B, 0xF1, 			//mov rsi,rcx
			0x48, 0x89
		};		
		contentOfAHook.AddRange(vars.injectedPtrForLevelSystemBytes);		//mov [injectedPtrForLevelSystemPtr],rcx
		contentOfAHook.AddRange(new byte[] { 0xC3 } ); 	//ret

		print("[NOLOADS] Scanning for signature (LevelSystem:Update)");

		foreach (var page in game.MemoryPages())
		{
			var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
			if ((vars.functionAddress = scanner.Scan(vars.sigScanTarget)) != IntPtr.Zero)
				break;
		}
		
		if (vars.functionAddress == IntPtr.Zero)
			throw new Exception("[NOLOADS] CANT FIND SIGNATURE");
		else
		{
			print("[NOLOADS] FOUND SIGNATURE AT: 0x" + vars.functionAddress.ToString("X4"));
			
			vars.allocation = game.AllocateMemory(contentOfAHook.Count);
			game.Suspend();

			try
			{
				//Write hook content into memory
				vars.oInitPtr = game.WriteBytes((IntPtr)vars.allocation, contentOfAHook.ToArray());
				game.WriteCallInstruction((IntPtr)vars.functionAddress, (IntPtr)vars.allocation );
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
	}
}

split
{
}

start
{
}

isLoading
{
	//return game.ReadValue<bool>((IntPtr)vars.injectedIsLoadingPtr);
}