local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PoolConstants = require(ReplicatedStorage.Libraries.GameSpecific.Pool.PoolConstants)

local PoolBotProfiles = {}

local v = {
	Difficulty = "Beginner",
	HigherDifficulty = "Rookie",
	Record = {
		Levels = { Min = 2, Max = 25 },
		WinRate = { Min = 0.42, Max = 0.54 }
	},
	FirstNames = { "Alex", "Sam", "Jordan", "Taylor", "Chris", "Morgan", "Casey", "Riley" },
	LastNames = { "Lee", "Kim", "Cole", "Grant", "Reed", "Hayes", "Brooks", "Wells" }
}

PoolBotProfiles.Countries = {
	Brazil = {
		Difficulty = "Beginner",
		HigherDifficulty = "Rookie",
		Record = {
			Levels = { Min = 2, Max = 25 },
			WinRate = { Min = 0.42, Max = 0.54 }
		},
		FirstNames = {
			"Gabriel",
			"Beatriz",
			"Lucas",
			"Larissa",
			"Rafael",
			"Mariana",
			"Thiago",
			"Isabela",
			"Pedro",
			"Leticia"
		},
		LastNames = {
			"Silva",
			"Santos",
			"Oliveira",
			"Souza",
			"Costa",
			"Pereira",
			"Almeida",
			"Rocha"
		}
	},
	UnitedStates = {
		Difficulty = "Rookie",
		HigherDifficulty = "Amateur",
		LowerDifficulty = "Beginner",
		Record = {
			Levels = { Min = 6, Max = 45 },
			WinRate = { Min = 0.45, Max = 0.56 }
		},
		FirstNames = {
			"Jake",
			"Ava",
			"Mason",
			"Madison",
			"Tyler",
			"Harper",
			"Caleb",
			"Brooklyn",
			"Austin",
			"Sofia"
		},
		LastNames = {
			"Johnson",
			"Miller",
			"Davis",
			"Carter",
			"Parker",
			"Turner",
			"Bennett",
			"Rivera"
		}
	},
	Indonesia = {
		Difficulty = "Rookie",
		HigherDifficulty = "Amateur",
		LowerDifficulty = "Beginner",
		Record = {
			Levels = { Min = 12, Max = 80 },
			WinRate = { Min = 0.47, Max = 0.57 }
		},
		FirstNames = {
			"Budi",
			"Siti",
			"Rizky",
			"Putri",
			"Dimas",
			"Ayu",
			"Fajar",
			"Dewi",
			"Arif",
			"Intan"
		},
		LastNames = {
			"Santoso",
			"Wijaya",
			"Pratama",
			"Saputra",
			"Hidayat",
			"Kusuma",
			"Nugroho",
			"Setiawan"
		}
	},
	Argentina = {
		Difficulty = "Amateur",
		HigherDifficulty = "Regular",
		LowerDifficulty = "Rookie",
		Record = {
			Levels = { Min = 25, Max = 140 },
			WinRate = { Min = 0.49, Max = 0.59 }
		},
		FirstNames = {
			"Santino",
			"Martina",
			"Thiago",
			"Catalina",
			"Benjamin",
			"Delfina",
			"Joaquin",
			"Morena",
			"Lautaro",
			"Abril"
		},
		LastNames = {
			"Gonzalez",
			"Rodriguez",
			"Fernandez",
			"Romero",
			"Sosa",
			"Alvarez",
			"Acosta",
			"Benitez"
		}
	},
	UnitedKingdom = {
		Difficulty = "Regular",
		HigherDifficulty = "Shark",
		LowerDifficulty = "Amateur",
		Record = {
			Levels = { Min = 45, Max = 220 },
			WinRate = { Min = 0.51, Max = 0.61 }
		},
		FirstNames = {
			"Oliver",
			"Amelia",
			"Harry",
			"Isla",
			"George",
			"Poppy",
			"Alfie",
			"Freya",
			"Archie",
			"Evie"
		},
		LastNames = { "Smith", "Jones", "Taylor", "Evans", "Hughes", "Wright", "Walker", "Clarke" }
	},
	Mexico = {
		Difficulty = "Regular",
		HigherDifficulty = "Shark",
		LowerDifficulty = "Amateur",
		Record = {
			Levels = { Min = 70, Max = 300 },
			WinRate = { Min = 0.52, Max = 0.62 }
		},
		FirstNames = {
			"Diego",
			"Ximena",
			"Santiago",
			"Valentina",
			"Mateo",
			"Camila",
			"Emiliano",
			"Regina",
			"Leonardo",
			"Renata"
		},
		LastNames = {
			"Hernandez",
			"Garcia",
			"Martinez",
			"Lopez",
			"Ramirez",
			"Flores",
			"Morales",
			"Cruz"
		}
	},
	Canada = {
		Difficulty = "Regular",
		HigherDifficulty = "Shark",
		LowerDifficulty = "Amateur",
		Record = {
			Levels = { Min = 100, Max = 400 },
			WinRate = { Min = 0.53, Max = 0.63 }
		},
		FirstNames = {
			"Liam",
			"Olivia",
			"Noah",
			"Emma",
			"Owen",
			"Chloe",
			"Logan",
			"Maeve",
			"Ethan",
			"Charlotte"
		},
		LastNames = {
			"Tremblay",
			"Gagnon",
			"Roy",
			"MacDonald",
			"Campbell",
			"Bouchard",
			"Wilson",
			"Leblanc"
		}
	},
	Turkey = {
		Difficulty = "Regular",
		HigherDifficulty = "Shark",
		LowerDifficulty = "Amateur",
		Record = {
			Levels = { Min = 700, Max = 2400 },
			WinRate = { Min = 0.61, Max = 0.73 }
		},
		FirstNames = {
			"Emir",
			"Zeynep",
			"Mehmet",
			"Elif",
			"Yusuf",
			"Defne",
			"Can",
			"Ayse",
			"Burak",
			"Ece"
		},
		LastNames = { "Yilmaz", "Kaya", "Demir", "Sahin", "Celik", "Yildiz", "Aydin", "Ozturk" }
	},
	Philippines = {
		Difficulty = "Regular",
		HigherDifficulty = "Shark",
		LowerDifficulty = "Amateur",
		Record = {
			Levels = { Min = 120, Max = 470 },
			WinRate = { Min = 0.54, Max = 0.64 }
		},
		FirstNames = {
			"Jose",
			"Andrea",
			"Miguel",
			"Angel",
			"Paolo",
			"Bea",
			"Carlo",
			"Jasmine",
			"Rafael",
			"Kristine"
		},
		LastNames = {
			"Santos",
			"Reyes",
			"Cruz",
			"Bautista",
			"Garcia",
			"Mendoza",
			"Villanueva",
			"Dela Cruz"
		}
	},
	Italy = {
		Difficulty = "Regular",
		HigherDifficulty = "Shark",
		LowerDifficulty = "Amateur",
		Record = {
			Levels = { Min = 150, Max = 550 },
			WinRate = { Min = 0.55, Max = 0.65 }
		},
		FirstNames = {
			"Leonardo",
			"Giulia",
			"Francesco",
			"Sofia",
			"Lorenzo",
			"Aurora",
			"Matteo",
			"Chiara",
			"Andrea",
			"Alessia"
		},
		LastNames = {
			"Rossi",
			"Russo",
			"Ferrari",
			"Esposito",
			"Bianchi",
			"Romano",
			"Ricci",
			"Marino"
		}
	},
	Spain = {
		Difficulty = "Shark",
		HigherDifficulty = "Legend",
		LowerDifficulty = "Regular",
		Record = {
			Levels = { Min = 900, Max = 3200 },
			WinRate = { Min = 0.62, Max = 0.75 }
		},
		FirstNames = {
			"Alejandro",
			"Lucia",
			"Pablo",
			"Carmen",
			"Javier",
			"Paula",
			"Sergio",
			"Elena",
			"Diego",
			"Marta"
		},
		LastNames = {
			"Garcia",
			"Fernandez",
			"Lopez",
			"Martinez",
			"Sanchez",
			"Perez",
			"Gomez",
			"Navarro"
		}
	},
	Thailand = {
		Difficulty = "Regular",
		HigherDifficulty = "Shark",
		LowerDifficulty = "Amateur",
		Record = {
			Levels = { Min = 220, Max = 750 },
			WinRate = { Min = 0.56, Max = 0.67 }
		},
		FirstNames = {
			"Somchai",
			"Ploy",
			"Krit",
			"Nong",
			"Anan",
			"Mali",
			"Thanawat",
			"Fah",
			"Niran",
			"Pim"
		},
		LastNames = {
			"Srisai",
			"Chaiyaporn",
			"Boonmee",
			"Suksawat",
			"Rattanakorn",
			"Wongsa",
			"Kaewmanee",
			"Thongdee"
		}
	},
	NineBall = {
		Difficulty = "Rookie",
		HigherDifficulty = "Amateur",
		LowerDifficulty = "Beginner",
		Record = {
			Levels = { Min = 8, Max = 120 },
			WinRate = { Min = 0.46, Max = 0.58 }
		},
		FirstNames = {
			"Lucas",
			"Mia",
			"Diego",
			"Aiko",
			"Noah",
			"Sofia",
			"Rizky",
			"Emma",
			"Mateo",
			"Leon",
			"Isla",
			"Paolo"
		},
		LastNames = {
			"Silva",
			"Kim",
			"Garcia",
			"Muller",
			"Santos",
			"Rossi",
			"Tremblay",
			"Reyes",
			"Smith",
			"Wijaya"
		}
	},
	Germany = {
		Difficulty = "Regular",
		HigherDifficulty = "Shark",
		LowerDifficulty = "Amateur",
		Record = {
			Levels = { Min = 270, Max = 900 },
			WinRate = { Min = 0.57, Max = 0.68 }
		},
		FirstNames = {
			"Lukas",
			"Mia",
			"Felix",
			"Hannah",
			"Jonas",
			"Lena",
			"Paul",
			"Emilia",
			"Leon",
			"Marie"
		},
		LastNames = {
			"Muller",
			"Schmidt",
			"Schneider",
			"Fischer",
			"Weber",
			"Wagner",
			"Becker",
			"Hoffmann"
		}
	},
	Monaco = {
		Difficulty = "Regular",
		HigherDifficulty = "Shark",
		LowerDifficulty = "Amateur",
		Record = {
			Levels = { Min = 320, Max = 1100 },
			WinRate = { Min = 0.58, Max = 0.69 }
		},
		FirstNames = {
			"Louis",
			"Charlotte",
			"Pierre",
			"Camille",
			"Antoine",
			"Gabrielle",
			"Hugo",
			"Pauline",
			"Andrea",
			"Stephanie"
		},
		LastNames = {
			"Bertrand",
			"Lorenzi",
			"Pastor",
			"Gastaud",
			"Notari",
			"Boeri",
			"Campora",
			"Fautrier"
		}
	},
	Greece = {
		Difficulty = "Regular",
		HigherDifficulty = "Shark",
		LowerDifficulty = "Amateur",
		Record = {
			Levels = { Min = 500, Max = 1800 },
			WinRate = { Min = 0.6, Max = 0.72 }
		},
		FirstNames = {
			"Giorgos",
			"Maria",
			"Nikos",
			"Eleni",
			"Dimitris",
			"Katerina",
			"Kostas",
			"Sofia",
			"Yannis",
			"Anna"
		},
		LastNames = {
			"Papadopoulos",
			"Pappas",
			"Georgiou",
			"Nikolaidis",
			"Vlachos",
			"Karagiannis",
			"Christodoulou",
			"Alexiou"
		}
	}
}

local clones = {}

function PoolBotProfiles.Get(p: string)
	local country = PoolBotProfiles.Countries[p]

	if country then
		return country
	end

	local v2 = clones[p]

	if v2 then
		return v2
	end

	local venue = PoolConstants.GetVenue(p)
	local playsLike = venue and venue.PlaysLike

	if not (venue and playsLike) then
		return v
	end

	local v3 = PoolBotProfiles.Countries[playsLike] or v
	local v4

	if venue.Country then
		v4 = PoolBotProfiles.Countries[venue.Country] or v3
	else
		v4 = v3
	end

	local clone = table.clone(v3)

	clone.FirstNames = v4.FirstNames
	clone.LastNames = v4.LastNames
	clones[p] = clone

	return clone
end

function PoolBotProfiles.GetRecord(p: string)
	return PoolBotProfiles.Get(p).Record or v.Record
end

function PoolBotProfiles.Harder(p)
	return p.HigherDifficulty or p.Difficulty
end

function PoolBotProfiles.Easier(p)
	return p.LowerDifficulty or p.Difficulty
end

local function pick(list, object) -- 2 equivalent calls inferred from this helper
	return list[object:NextInteger(1, #list)]
end

local function compact(value: string) -- 3 equivalent calls inferred from this helper
	return (string.gsub(value, "%s+", ""))
end

function PoolBotProfiles.Pick(p: string, p2, flag: boolean?, flag2: boolean?, p3: string?)
	local v2 = p2 or Random.new()
	local v3 = PoolBotProfiles.Get(p)
	local v4 = pick(v3.FirstNames, v2) -- inferred equivalent call
	local v5 = pick(v3.LastNames, v2) -- inferred equivalent call
	local integer = v2:NextInteger(1, 4)
	local displayName

	if integer == 1 then
		displayName = v4 .. " " .. v5
	elseif integer == 2 then
		displayName = string.lower(v4) .. "_" .. string.lower(compact(v5)) .. v2:NextInteger(1, 99) -- inferred equivalent call
	elseif integer == 3 then
		displayName = v4 .. string.sub(compact(v5), 1, 1) -- inferred equivalent call
	else
		displayName = v4 .. v2:NextInteger(100, 2999)
	end

	local difficulty

	if flag then
		difficulty = PoolBotProfiles.Harder(v3)
	elseif flag2 then
		difficulty = p3 or PoolBotProfiles.Easier(v3)
	else
		difficulty = v3.Difficulty
	end

	return {
		Name = compact(displayName), -- inferred equivalent call
		DisplayName = displayName,
		Difficulty = difficulty,
		SteppedUp = flag == true and difficulty ~= v3.Difficulty,
		SteppedDown = flag2 == true and not flag and difficulty ~= v3.Difficulty
	}
end

return PoolBotProfiles