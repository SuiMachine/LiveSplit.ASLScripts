state("") {}

startup
{
	vars.Dbg = (Action<dynamic>) ((output) => print("[Mono ASL] " + output));
}

init
{
	vars.TokenSource = new CancellationTokenSource();
	vars.MonoFinder = new Thread(() =>
	{
		vars.Dbg("Starting mono scan thread.");

		uint ASM_CS_HASH = 0xFA381AED;
		int PTR_SIZE = 0x4;
		//                     size, items, next
		int[] OFFSETS_TABLE = { 0xC,   0x8,  0x8 };
		//                      cache, size, items
		int[] OFFSETS_CACHE = { 0x358,  0x8,  0x10 };
		//                    parent, name, space, static, fields, runtime,  next
		int[] OFFSETS_KLASS = { 0x20, 0x2C,  0x30,   0x40,   0x60,    0x84, 0xA8 };
		//                      next, name, offset
		int[] OFFSETS_FIELD = { 0x10,  0x4,    0xC };

		SignatureScanner MonoScanner = null;
		var mono_image_loaded = new SigScanTarget(2, "FF 35 ???????? E8 ???????? 83 C4 08 8B F0 83 3D ???????? 00");
		mono_image_loaded.OnFound = (p, s, ptr) => p.ReadPointer(ptr);
		IntPtr loaded_images = IntPtr.Zero, Asm_Cs_image = IntPtr.Zero;

		vars.Mono = new Dictionary<string, Dictionary<string, IntPtr>>();

		var Token = vars.TokenSource.Token;
		while (!Token.IsCancellationRequested)
		{
			var Mono = game.ModulesWow64Safe().FirstOrDefault(m => m.ModuleName.StartsWith("mono"));
			if (Mono == null)
			{
				vars.Dbg("Could not find Mono module. Trying again.");
				Thread.Sleep(2000);
				continue;
			}

			MonoScanner = new SignatureScanner(game, Mono.BaseAddress, Mono.ModuleMemorySize);
			break;
		}

		while (!Token.IsCancellationRequested)
		{
			loaded_images = MonoScanner.Scan(mono_image_loaded);
			if (loaded_images == IntPtr.Zero)
			{
				vars.Dbg("Could not resolve mono_image_loaded signature. Trying again.");
				Thread.Sleep(2000);
				continue;
			}

			break;
		}

		while (!Token.IsCancellationRequested)
		{
			var ghashtable = IntPtr.Zero;
			var size = new DeepPointer(loaded_images, OFFSETS_TABLE[0]).Deref<int>(game);
			new DeepPointer(loaded_images, OFFSETS_TABLE[1], PTR_SIZE * (int)(ASM_CS_HASH % size)).DerefOffsets(game, out ghashtable);

			for (var ptr = game.ReadPointer(ghashtable); ptr != IntPtr.Zero; ptr = game.ReadPointer(ptr + OFFSETS_TABLE[2]))
			{
				string name = new DeepPointer(ptr, 0x0).DerefString(game, 32, "");
				if (name != "Assembly-CSharp") continue;

				Asm_Cs_image = game.ReadPointer(ptr + PTR_SIZE);
				break;
			}

			if (Asm_Cs_image == IntPtr.Zero)
			{
				vars.Dbg("Assembly-CSharp was not found in the loaded images. Trying again.");
				Thread.Sleep(2000);
				continue;
			}

			break;
		}

		Func<string, string> cleanString = (input) =>
		{
			if (input.Contains("BackingField")) input = System.Text.RegularExpressions.Regex.Matches(input, @"<(.+)>k__BackingField")[0].Groups[1].Value;
			if (input.Contains("`")) input = input.Remove(input.IndexOf("`"));
			return input;
		};

		Func<IntPtr, Dictionary<string, IntPtr>> findStatics = (klass) =>
		{
			var fields = new Dictionary<string, IntPtr>();
			IntPtr mono_fields = game.ReadPointer(klass + OFFSETS_KLASS[4]), ptr = game.ReadPointer(mono_fields + OFFSETS_FIELD[1]);

			for (int i = 0; ptr != IntPtr.Zero; i += OFFSETS_FIELD[0], ptr = game.ReadPointer(mono_fields + OFFSETS_FIELD[1] + i))
			{
				var type = new DeepPointer(mono_fields + i, PTR_SIZE).Deref<short>(game);
				var name = cleanString(new DeepPointer(mono_fields + OFFSETS_FIELD[1] + i, 0x0).DerefString(game, 64, ""));
				var offset = game.ReadValue<int>(mono_fields + OFFSETS_FIELD[2] + i);
				if (string.IsNullOrEmpty(name) || type < 0x10 || type > 0x17 || fields.ContainsKey(name)) continue;

				// vars.Dbg("    Found field " + name + " (0x" + offset.ToString("X") + ")");
				fields.Add(name, new DeepPointer(klass + OFFSETS_KLASS[5], PTR_SIZE, OFFSETS_KLASS[3]).Deref<IntPtr>(game) + offset);
			}

			return fields;
		};

		while (!Token.IsCancellationRequested)
		{
			var size = game.ReadValue<int>(Asm_Cs_image + OFFSETS_CACHE[0] + OFFSETS_CACHE[1]);
			var monovtable = game.ReadPointer(Asm_Cs_image + OFFSETS_CACHE[0] + OFFSETS_CACHE[2]);

			if (size == 0)
			{
				vars.Dbg("Class cache is empty. Wrong offsets? Trying again.");
				vars.Dbg(size);
				Thread.Sleep(2000);
				continue;
			}

			for (int i = 0; i < size; ++i)
			{
				for (var klass = game.ReadPointer(monovtable + PTR_SIZE * i); klass != IntPtr.Zero; klass = game.ReadPointer(klass + OFFSETS_KLASS[3]))
				{
					string class_namespace = new DeepPointer(klass + OFFSETS_KLASS[2], 0x0).DerefString(game, 128, "default");
					if (class_namespace.Length > 0) continue;

					string class_name = new DeepPointer(klass + OFFSETS_KLASS[1], 0x0).DerefString(game, 128, "");
					if (vars.Mono.ContainsKey(class_name) || string.IsNullOrEmpty(class_name)) continue;

					// vars.Dbg("Found class " + class_name + " (0x" + klass.ToString("X") + ")");
					var static_fields = findStatics(klass);
					if (static_fields.Count <= 0) continue;

					vars.Dbg(string.Format("Added class '{0}' with fields\n{1}", class_name, string.Join(",\n", static_fields.Keys)));
					vars.Mono.Add(class_name, static_fields);
				}
			}

			break;
		}

		vars.Dbg("Exiting mono scan thread.");
	});

	vars.MonoFinder.Start();

	vars.bool = (Func<dynamic, int[], bool>) ((field, offsets) => new DeepPointer((IntPtr)field, offsets).Deref<bool>(game));
	vars.int = (Func<dynamic, int[], int>) ((field, offsets) => new DeepPointer((IntPtr)field, offsets).Deref<int>(game));
	vars.float = (Func<dynamic, int[], float>) ((field, offsets) => new DeepPointer((IntPtr)field, offsets).Deref<float>(game));
	vars.double = (Func<dynamic, int[], double>) ((field, offsets) => new DeepPointer((IntPtr)field, offsets).Deref<double>(game));
	vars.string = (Func<dynamic, int[], int, string>) ((field, offsets, length) => new DeepPointer((IntPtr)field, offsets).DerefString(game, length));
	vars.intptr = (Func<dynamic, int[], IntPtr>) ((field, offsets) => new DeepPointer((IntPtr)field, offsets).Deref<IntPtr>(game));
}

update
{
	if (vars.MonoFinder.IsAlive) return false;
}

exit
{
	vars.TokenSource.Cancel();
}

shutdown
{
	vars.TokenSource.Cancel();
}