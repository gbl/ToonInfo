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

-- If the value is an exact border, probability is much higher that
-- we can't raise the faction anymore, so let's show the green bar.

	if (value==26000 or value==36000 or value==56000 or value==91000 or value==151000) then
		width=(118)
		frame:SetBackgroundColor(0, 1, 0, 0.5)		-- green
	elseif (value < 23000) then		-- not seen yet but let's at least handle this case
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

	factionWindow=ToonInfo.CreateScrollableRiftWindow("RiftWindow", L("Factions"), context)

	local nameforid={}
	local idlist={}
	local toon, data
	local i, n, m
	local row, lastcatname, catname
	
	for toon,data in pairs(ToonInfoShard) do
		if (data["faction"] ~= nil) and (data["guild"] ~= true) then
			for id, amount in pairs(data["faction"]) do
				-- this is a workaround for a faction id that two of my older chars have,
				-- my newer chars don't have, which isn't shown in the standard ui faction window,
				-- and for which Inspect.Faction.Detail returns nil. Let's just ignore it.
				if id ~= "f000000011D951280" and not nameforid[id] then
					detail=Inspect.Faction.Detail(id)
					if detail ~= nil then
						if detail.name then
							ToonInfoGlobal["factionname"][id]=detail.name
						end
						if detail.categoryName then
							ToonInfoGlobal["factioncategory"][id]=detail.categoryName
						end
					end
					ToonInfoGlobal["factionname"][id]=(ToonInfoGlobal["factionname"][id] or "???")
					ToonInfoGlobal["factioncategory"][id]=(ToonInfoGlobal["factioncategory"][id] or "???")
					name=ToonInfoGlobal["factionname"][id]
					catname=ToonInfoGlobal["factioncategory"][id]
					nameforid[id]=catname .. "|" .. name
					table.insert(idlist, id)
				end			
			end
		end
	end
	table.sort(idlist, function(a,b) return nameforid[a]<nameforid[b] end)
	factionWindow.factionrows={}

	row=UI.CreateFrame("Frame", "FactionRowHeader", factionWindow);
	row:SetPoint("TOPLEFT", factionWindow, "TOPLEFT", 0, 0)
	row:SetHeight(70)
	factionWindow.header=row

	row.toons={}

	n=1
	for toon, data in pairs(ToonInfoShard) do
		if (data["faction"] ~= nil) and (data["guild"] ~= true) then
			text=UI.CreateFrame("Text", "FactionRowHeader"..toon, row)
			text:SetPoint("TOPLEFT", row, "TOPLEFT", 210-120+n*120, 0)
			text:SetWidth(118)
			text:SetHeight(30)
			text:SetFontSize(16)
			text:SetText(toon)
			row.toons[toon]=text
			n=n+1
		end
	end

	m=1
	lastcatname=""
	for i,id in ipairs(idlist) do
		if ToonInfoGlobal["factioncategory"][id] ~= lastcatname then
			lastcatname=ToonInfoGlobal["factioncategory"][id]
			row=UI.CreateFrame("Text", "FactionHeader"..lastcatname, factionWindow)
			row:SetPoint("TOPLEFT", factionWindow, "TOPLEFT", 0, 10+m*32)
			row:SetHeight(30)
			row:SetWidth(210-120+n*120)
			row:SetFontSize(16)
			row:SetBackgroundColor(0.5, 0.5, 0.8, 1)
			row:SetText(lastcatname)
			m=m+1
		end	
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
		text:SetText(ToonInfoGlobal["factionname"][id])
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

	factionWindow:SetHeight(10+m*32)
	factionWindow:SetWidth(214-120+n*120)
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

function ToonInfo.forgetFactionWindow()
	if factionWindow then
		factionWindow:SetVisible(false)
		factionWindow=nil
	end
end
