state("Transistor")
{
}

init
{
	var sw = new Stopwatch();
	sw.Start();
	var total = 0L;
	var filtered = 0L;
	// scan two things in one pass!
	var target = new SigScanTarget(0, new byte[] { 0x00, 0x00, 0x4D, 0x6F, 0x6E, 0x6F, 0x47, 0x61, 0x6D, 0x65, 0x2E, 0x46, 0x72, 0x61, 0x6D, 0x65, 0x77, 0x6F, 0x72, 0x6B, 0x2E, 0x57, 0x69, 0x6E, 0x64, 0x6F, 0x77, 0x73, 0x00, 0x00, 0x00, 0x00 });
	foreach (var page in memory.MemoryPages())
	{
		var bytes = memory.ReadBytes(page.BaseAddress, (int)page.RegionSize);
		if (bytes == null)
		continue;
	
		var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);
		vars.addr = scanner.Scan(target); 
		
		//print(String.Format("0x{0:X} {1} {2} {3}", (long)page.BaseAddress, page.RegionSize, page.Protect, page.Type));
		if (vars.addr != IntPtr.Zero)
		{
			//print("found at 0x" + vars.addr.ToString("X"));
			break;
		}
	}
	vars.loadingAddress = vars.addr + (int)-0x3DC;
}


update
{
    vars.loadingAddress = vars.addr + (int)-0x3DC;
	vars.isLoading = memory.ReadValue<bool>((IntPtr)vars.loadingAddress);
	//print(Convert.ToString(vars.isLoading));
}


isLoading 
{
	return vars.isLoading;
}
