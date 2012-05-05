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
	}
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
