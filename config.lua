Config                            = {}
Config.Locale       = 'en'

Config.DrawDistance = 100.0
Config.ZoneSize    = {x = 1.6, y = 1.6, z = 0.6}
Config.MarkerColor                = { r = 98, g = 0, b = 255 }

Config.MarkerType   = 23

Config.RequiredCopsMorf  = 0

Config.TimeToFarm    = 1 * 1000
Config.TimeToProcess = 1 * 1000
Config.TimeToSell    = 1  * 1000

Config.Zones = {
	MorfField =			{x = 351.96,	y = 13.26,	z = 91.13,	name = _U('opium_field'),		sprite = 51,	color = 60},
	MorfProcessing =	{x = 351.82,	y = 4.57,	z = 91.13,	name = _U('opium_processing'),	sprite = 51,	color = 60},
}

Config.Blips = {
    ['drugs1'] = vector3(452.51, -1025.28, 27.54),
}

Config.List = {
	[1] = 'SNS', -- Nazwa Borni (Label - Wyświetlana nazwa) 60k
	[2] = 'snspistol', -- Nazwa Borni (Spawn - Spawn borni) 60k
	[3] = 'SNS MK2', -- Nazwa Borni (Label - Wyświetlana nazwa) 80k
	[4] = 'snspistol_mk2', -- Nazwa Borni (Spawn - Spawn borni) 80k
	[5] = 'Pistolet', -- Nazwa Borni (Label - Wyświetlana nazwa) 90k
	[6] = 'pistol', -- Nazwa Borni (Spawn - Spawn borni) 90k
	[7] = 'Pistolet MK2', -- Nazwa Borni (Label - Wyświetlana nazwa) 100k
	[8] = 'pistol_mk2', -- Nazwa Borni (Spawn - Spawn borni) 100k
	[9] = 'Vintage', -- Nazwa Borni (Label - Wyświetlana nazwa) 120k
	[10] = 'vintagepistol', -- Nazwa Borni (Spawn - Spawn borni) 120k
	[11] = 'machete', -- Nazwa Borni (Spawn - Spawn borni) 15k
	[12] = 'Toporek', -- Nazwa Borni (Spawn - Spawn borni) 15k
	[13] = 'battleaxe', -- Nazwa Borni (Spawn - Spawn borni) 15k
	[14] = 'Kij bejsbolowy', -- Nazwa Borni (Spawn - Spawn borni) 10k
	[15] = 'bat', -- Nazwa Borni (Spawn - Spawn borni) 10k
	[16] = 'Nóż', -- Nazwa Borni (Spawn - Spawn borni) 20k
	[17] = 'knife', -- Nazwa Borni (Spawn - Spawn borni) 20k
}   

Config.Organisations = {
    ['drugs1'] = {
		Label = 'Prywatne Drugi #1',
		Cloakroom = {
			coords = vector3(-1534.66, 131.25, 57.37),
		},
		Inventory = {
			coords = vector3(359.73, -1.44, 90.42),
			from = 1, -- grade od ktorego to ma
		},
		BossMenu = {
			coords = vector3(367.47, -4.46, 90.42),
			from = 1 -- grade od ktorego to ma
		},
		DrugsSettings = {
			from = 1 -- grade od ktorego to ma
		},

 	},
}

Config.Interactions = {
    ['drugs1'] = {
		handcuffs = 0, 
		repair = 0,
		worek = 0
	},
}

Config.BlipTime = 300 -- W sekundach
Config.Cooldown = 300 -- W sekundach

Config.Jobs = {
	'drugs1',
}