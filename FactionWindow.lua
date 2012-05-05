local function L(x) return Translations.ToonInfo.L(x) end

local factionWindow

local function formatfaction(name, amount)
	if (amount < 23000) then
		return (amount).."/23000"
	elseif (amount < 26000) then
		return (amount-23000).."/3000"
	elseif (amount < 36000) then
		return (amount-26000).."/10000"
	elseif (amount < 56000) then
		return (amount-36000).."/20000"
	elseif (amount < 91000) then
		return (amount-56000).."/35000"
	elseif (amount < 151000) then
		return (amount-91000).."/60000"
	else
		return ""
	end
end

local function notoriety(name, amount)
	if (amount < 23000) then	-- not in game
		return L("hated")
	elseif (amount < 26000) then
		return L("neutral")
	elseif (amount < 36000) then
		return L("friendly")
	elseif (amount < 56000) then
		return L("decorated")
	elseif (amount < 91000) then
		return L("honored")
	elseif (amount < 151000) then
		return L("revered")
	else
		return L("glorified")
	end
end

local function setColorAndWidth(frame, value)
	local width
--	print("value="..value)
	if (value < 23000) then		-- not seen yet but let's at least handle this case
		width=(118)
		frame:SetBackgroundColor(1, 0, 0, 0.5)		-- red
	elseif (value < 26000) then	-- neutral
		width=(118*(value-23000)/(26000-23000))
		frame:SetBackgroundColor(1, 1, 0, 0.5)		-- yellow
	elseif (value < 36000) then	-- "friendly"
		width=(118*(value-26000)/(36000-26000))
		frame:SetBackgroundColor(0, 1/3, 1, 0.5)	-- dark blue
	elseif (value < 56000) then	-- "decorated"
		width=(118*(value-36000)/(56000-36000))
		frame:SetBackgroundColor(0.5, 2/3, 1, 0.5)	-- bluish
	elseif (value < 91000) then	-- "honored"
		width=(118*(value-56000)/(91000-56000))
		frame:SetBackgroundColor(0, 1, 1, 0.5)		-- cyan
	elseif (value < 151000) then	-- "revered"
		width=(118*(value-91000)/(151000-91000))
		frame:SetBackgroundColor(0, 1, 1, 0.5)		-- blue/green
	else   				-- "glorified"
		width=(118)
		frame:SetBackgroundColor(0, 1, 0, 0.5)		-- green
	end
--	print("width="..width)
	frame:SetWidth(math.floor(width))
end

function ToonInfo.BuildFactionWindow(context)
	if factionWindow then
		return
	end

	factionWindow=UI.CreateFrame("RiftWindow", "ToonInfo", context)
	factionWindow:SetTitle(L("Factions"))
	factionWindow:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	factionWindow:SetController("content")
	factionWindow:SetWidth(440)
	factionWindow:SetBackgroundColor(0, 0, 0, 1)

	local closeButton = UI.CreateFrame("RiftButton", "ToonInfoCloseFactionButton", factionWindow)
	closeButton:SetSkin("close")
	closeButton:SetPoint("TOPRIGHT", factionWindow, "TOPRIGHT", 0, -40)
	function closeButton.Event:LeftPress()
		factionWindow:SetVisible(false)
	end

	local haveid={}
	local idlist={}
	for toon,data in pairs(ToonInfoShard) do
		if (data["faction"] ~= nil) and (data["guild"] ~= true) then
			for id, amount in pairs(data["faction"]) do
				if not haveid[id] then
					haveid[id]=true
					table.insert(idlist, id)
				end
			end
		end
	end
	table.sort(idlist)
	factionWindow.factionrows={}
	local n=1, m
	local row
	row=UI.CreateFrame("Frame", "FactionRowHeader", factionWindow);
	row:SetPoint("TOPLEFT", factionWindow, "TOPLEFT", 0, 0)
	row:SetHeight(70)
	factionWindow.header=row

	row.toons={}

	n=1
	for toon, data in pairs(ToonInfoShard) do
		if (data["faction"] ~= nil) and (data["guild"] ~= true) then
			text=UI.CreateFrame("Text", "FactionRowHeader"..toon, row)
			text:SetPoint("TOPLEFT", row, "TOPLEFT", 250-120+n*120, 0)
			text:SetWidth(118)
			text:SetHeight(30)
			text:SetFontSize(16)
			text:SetText(toon)
			row.toons[toon]=text
			n=n+1
		end
	end

	m=1
	for i,id in ipairs(idlist) do
		row=UI.CreateFrame("Frame", "FactionRow"..i, factionWindow);
		row:SetPoint("TOPLEFT", factionWindow, "TOPLEFT", 0, 10+m*32)
		row:SetHeight(30)
		factionWindow.factionrows[id]=row
		local text
		local detail
		text=UI.CreateFrame("Text", "text", row)
		text:SetPoint("TOPLEFT", row, "TOPLEFT", 2, 0)
		text:SetWidth(210)
		text:SetHeight(30)
		text:SetFontSize(16)
		detail=Inspect.Faction.Detail(id)
		if detail ~= nil then
			if detail.name then text:SetText(detail.name) end
		else
			print("Inspect.Faction.Detail returns nil for "..id)
		end
		row.toons={}

		n=1
		for toon,data in pairs(ToonInfoShard) do
			if (data["faction"] ~= nil) and (data["guild"] ~= true) then
				local cell
				cell=UI.CreateFrame("Frame", "text", row)
				cell:SetPoint("TOPLEFT", row, "TOPLEFT", 214-120+n*120, 0)
				cell:SetWidth(118)
				cell:SetHeight(30)
				cell:SetBackgroundColor(0, 0, 0, 1)
				row.toons[toon]=cell
				
				cell.text=UI.CreateFrame("Text", "text", cell)
				cell.text:SetPoint("TOPLEFT", cell, "TOPLEFT", 0, 0)
				cell.text:SetWidth(118)
				cell.text:SetHeight(15)
				cell.text:SetBackgroundColor(0,0,0,1)
				cell.text:SetFontSize(12)
				cell.text:SetLayer(0)

				cell.numbers=UI.CreateFrame("Text", "text", cell)
				cell.numbers:SetPoint("BOTTOMLEFT", cell, "BOTTOMLEFT", 0, 0)
				cell.numbers:SetWidth(118)
				cell.numbers:SetHeight(15)
				cell.numbers:SetBackgroundColor(0,0,0,1)
				cell.numbers:SetFontSize(12)
				cell.numbers:SetLayer(0)

				cell.bar=UI.CreateFrame("Frame", "text", cell)
				cell.bar:SetPoint("BOTTOMLEFT", cell, "BOTTOMLEFT", 0, 0)
				cell.bar:SetHeight(15)
				cell.bar:SetLayer(1)

				if data["faction"] and data["faction"][id] then
					cell.text:SetText(notoriety(id, data["faction"][id]))
					cell.numbers:SetText(formatfaction(id, data["faction"][id]))
					setColorAndWidth(cell.bar, data["faction"][id])
				else
					cell.text:SetText("------")
					cell.numbers:SetText("")
					cell.bar:SetBackgroundColor(0, 0, 0, 0)
					cell.bar:SetWidth(0)
				end
				n=n+1
			end
		end
		factionWindow.factionrows[id]=row
		m=m+1
	end

--	factionWindow:SetHeight(80+m*32)
	factionWindow:SetWidth(214-120+n*120+40)
	factionWindow:SetVisible(false)
end

function ToonInfo.UpdateFactionWindow(toon, faction, value)
	if factionWindow 
	and factionWindow.factionrows[faction]
	and factionWindow.factionrows[faction].toons[toon] then
		factionWindow.factionrows[faction].toons[toon].text:SetText(notoriety(faction, value))
		factionWindow.factionrows[faction].toons[toon].numbers:SetText(formatfaction(faction, value))
		setColorAndWidth(factionWindow.factionrows[faction].toons[toon].bar, value)
	end
end

function ToonInfo.ToggleFactionWindow()
	factionWindow:SetVisible(not factionWindow:GetVisible())
end
