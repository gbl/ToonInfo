if not Translations then Translations = {} end
if not Translations.Tooninfo then Translations.ToonInfo = {} end

local translationTable = {
	["German"] = {
		["ToonInfo"]		   = "ToonInfo",
		["ToonInfo Version "]	   = "ToonInfo Version ",
		[" installed!"] 	   = " installiert!",
		["Found Items"]		   = "gefundene Gegenstände",
		["Currencies"]		   = "Währungen",
		["Factions"]		   = "Fraktionen",
		["Total"]		   = "Gesamt",
		
		hated			= "verhasst",
		neutral			= "neutral",
		friendly		= "verbündet",
		decorated		= "dekoriert",
		honored			= "geschätzt",
		revered			= "verehrt",
		glorified		= "verherrlicht",
		
		["can't find Toon "]	= "Kann Charakter nicht finden: ",
		["cannot delete information about yourself"] =
			"Kann Infomation über sich selbst nicht löschen",
		["merge mode set to "]	= "Verschmelzmodus ist nun ",
	},
	-- french version thanks to Leetah
	["French"] = {
		["ToonInfo"]		   = "ToonInfo",
		["ToonInfo Version "]	   = "ToonInfo Version ",
		[" installed!"] 	   = " installé!",
		["Found Items"]		   = "Objets Trouvés",
		["Currencies"]		   = "Fortune",
		["Factions"]		   = "Notoriété",
		["Total"]		   = "Total",
		
		hated			= "haï",
		neutral			= "neutre",
		friendly		= "amical",
		decorated		= "décoré",
		honored			= "honoré",
		revered			= "révéré",
		glorified		= "glorifié",
		
		["can't find Toon "]	= "Impossible de trouver Toon: ",
		["cannot delete information about yourself"] =
			"Impossible de supprimer des informations vous concernant",
		["merge mode set to "]	= "type de fusion réglé sur ",
	},
	-- russian version thanks to Aybolitus (incomplete, copied from Heartometer)
	["Russian"] = {
		["ToonInfo"]         	= "ToonInfo",
		["ToonInfo Version "]	= "Версия ToonInfo ",
		[" installed!"]         = " установлена!",

		hated           	= "Ненависть",
		neutral           	= "Нейтралитет",
		friendly       		= "Приятельство",
		decorated       	= "Дружба",
		honored           	= "Уважение",
		revered           	= "Почтение",
		glorified       	= "Превознесение",
	},
}

function Translations.ToonInfo.L(x)
	local lang=Inspect.System.Language()
	if  translationTable[lang]
	and translationTable[lang][x] then
		return translationTable[lang][x]
	elseif lang == "English"  then
		return x
	else
		print ("No translation yet for '" .. lang .. "'/'" .. x .. "'")
		return x
	end
end
