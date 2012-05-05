if ToonInfo then
	print ("ToonInfo already loaded")
	return
end

ToonInfo = {
	version = 0.1
}

local currentToon

local function L(x) return Translations.ToonInfo.L(x) end

local function ensureVariablesInited()
	if not ToonInfoChar then ToonInfoChar={} end	
	if not ToonInfoShard then ToonInfoShard={} end
	if not ToonInfoGlobal then ToonInfoGlobal={} end
	if not ToonInfoGlobal["currencyicon"] then ToonInfoGlobal["currencyicon"]={} end
	if not ToonInfoGlobal["currencyname"] then ToonInfoGlobal["currencyname"]={} end
end

local function itemChanged(updates)
	if not currentToon then		-- safety measure
		return
	end
	ensureVariablesInited()
	if not ToonInfoShard[currentToon.name] then
		ToonInfoShard[currentToon.name] = {}
	end
	if not ToonInfoGlobal[currentToon.name] then
		ToonInfoGlobal[currentToon.name] = {}
	end
	if not ToonInfoShard[currentToon.name]["slots"] then
		ToonInfoShard[currentToon.name]["slots"] = {}
	end
	ToonInfoShard[currentToon.name]["guild"]=false
	if currentToon.guild then
		if not ToonInfoShard[currentToon.guild] then
			ToonInfoShard[currentToon.guild] = {}
		end
		if not ToonInfoGlobal[currentToon.guild] then
			ToonInfoGlobal[currentToon.guild] = {}
		end
		if not ToonInfoShard[currentToon.guild]["slots"] then
			ToonInfoShard[currentToon.guild]["slots"] = {}
		end
		ToonInfoShard[currentToon.guild]["guild"]=true
	end
	for k, v in pairs(updates) do
		if k:sub(1, 2) == "sg" then
			index=currentToon.guild
			if not index then
				return
			end
		else
			index=currentToon.name
		end
		-- print (index .. "-" .. k .. ": " .. (v and v or "false"));
		if (v == "nil") then		-- guild bank closed
			if ToonInfoShard[index]["slots"][k] then
				ToonInfoShard[index]["slots"][k].OutOfDate=true
			end
		elseif (v) then
			ToonInfoShard[index]["slots"][k]=Inspect.Item.Detail(v)
		else
			ToonInfoShard[index]["slots"][k]=v
		end
	end
end

local function currencyChanged(currencies)
	if not currentToon then		-- safety measure
		return
	end
	ensureVariablesInited()
	if not ToonInfoShard[currentToon.name] then
		ToonInfoShard[currentToon.name] = {}
	end
	if not ToonInfoShard[currentToon.name]["money"] then
		ToonInfoShard[currentToon.name]["money"] = {}
	end
	for k, v in pairs(currencies) do
		ToonInfoShard[currentToon.name]["money"][k]=v
		ToonInfo.UpdateMoneyWindow(currentToon.name, k, v)
	end
end

local function factionChanged(factions)
	if not currentToon then		-- safety measure
		return
	end
	ensureVariablesInited()
	if not ToonInfoShard[currentToon.name] then
		ToonInfoShard[currentToon.name] = {}
	end
	if not ToonInfoShard[currentToon.name]["faction"] then
		ToonInfoShard[currentToon.name]["faction"] = {}
	end
	for k, v in pairs(factions) do
		ToonInfoShard[currentToon.name]["faction"][k]=v
		ToonInfo.UpdateFactionWindow(currentToon.name, k, v)
	end
end

-- This should go to VariablesLoaded, or to AddonLoaded, but for the
-- first few frames, Inspect.Unit.Detail("player") returns nil.
-- So we use the update cycle to retry till we get something useful.

local function systemUpdate()
	local items, currencies, factions
	if not currentToon then
		currentToon=Inspect.Unit.Detail("player")
		if not currentToon then
			return
		end
		items = Inspect.Item.List()
		itemChanged(items)
		currencies=Inspect.Currency.List()
		currencyChanged(currencies)
		factions=Inspect.Faction.List()
		factionChanged(factions)
		ToonInfoShard[currentToon.name]["character"]=currentToon
	end
end

function ToonInfo.printVersion()
	print(L("ToonInfo Version ") .. (ToonInfo.version) .. L(" installed!"))
end

function ToonInfo.printFactions()
	local factions=Inspect.Faction.List()
	for id,noto in pairs(factions) do
		local detail=Inspect.Faction.Detail(id)
		print (id.." is "..detail.name.." have "..detail.notoriety)
	end
end

function ToonInfo.printCoin()
	local currencies=Inspect.Currency.List()
	for id,amount in pairs(currencies) do
		local detail=Inspect.Currency.Detail(id)
		print (id.." is "..detail.name.." have "..detail.stack.." max "..(detail.stackMax or "-"))
	end
end

function ToonInfo.SlashHandler(args)
	local r = {}
	local numargs = 0
	for token in string.gmatch(args, "[^%s]+") do
		r[numargs] = token
		numargs=numargs+1
	end
	if numargs>0 then
		if r[0] == "version" then
			ToonInfo.printVersion()
		end
		if r[0] == "coin" then
			ToonInfo.printCoin()
		end
		if r[0] == "factions" then
			ToonInfo.printFactions()
		end
	end
end


local function addonLoaded(addon) 
	if (addon == "ToonInfo") then
		ToonInfo.printVersion()
		ensureVariablesInited()
		ToonInfo.createUI()
	end
end

local function tooltipShown(type, shown, buff)
	local item
	if (type == "item" or type == "itemtype") then
		item=Inspect.Item.Detail(shown);
--		print("Tooltip: type "..(type or "nil")..", shown "..(shown or "nil") .. ", name "..(item.name or "nil"))
		if item then
			ToonInfo.showTooltipExtension(item.name)
		end
	else
--		print("Tooltip: type "..(type or "nil")..", shown "..(shown or "nil"))
		ToonInfo.hideTooltipExtension()
	end
end

table.insert(Event.Item.Slot,   		{itemChanged, "ToonInfo", "ItemSlotUpdated"})
table.insert(Event.Item.Update, 		{itemChanged, "ToonInfo", "ItemUpdated"})
table.insert(Event.Currency,    		{currencyChanged, "ToonInfo", "CurrencyUpdated"})
table.insert(Event.Faction.Notoriety,   	{factionChanged, "ToonInfo", "FactionChanged"})
table.insert(Event.System.Update.Begin, 	{systemUpdate, "ToonInfo", "systemUpdate"})
table.insert(Command.Slash.Register("ti"), 	{ToonInfo.SlashHandler, "ToonInfo", "SlashHandler" })
table.insert(Event.Addon.Load.End, 		{addonLoaded, "ToonInfo", "AddonLoaded" })
table.insert(Event.Tooltip, 			{tooltipShown, "ToonInfo", "TooltipShown"})
