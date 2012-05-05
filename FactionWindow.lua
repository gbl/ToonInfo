local function L(x) return Translations.ToonInfo.L(x) end

local factionWindow

local function formatfaction(name, amount)
	if (amount < 23000) then
		return "hated"
	elseif (amount < 26000) then
		return "0/"..(amount-23000)
	elseif (amount < 36000) then
		return "1/"..(amount-26000)
	elseif (amount < 56000) then
		return "2/"..(amount-36000)
	elseif (amount < 91000) then
		return "3/"..(amount-56000)
	elseif (amount < 151000) then
		return "4/"..(amount-91000)
	else
		return "5"
	end
end

local function setColorAndWidth(frame, value)
	if (value < 23000) then		-- not seen yet but let's at least handle this case
		frame:SetWidth(118)
		frame:SetBackgroundColor(1, 0, 0, 0.5)		-- red
	elseif (value < 26000) then	-- neutral
		frame:SetWidth(118*(value-23000)/(26000-23000))
		frame:SetBackgroundColor(1, 1, 0, 0.5)		-- yellow
	elseif (value < 36000) then	-- "verbündet"
		frame:SetWidth(118*(value-26000)/(36000-26000))
		frame:SetBackgroundColor(0, 1/3, 1, 0.5)	-- dark blue
	elseif (value < 56000) then	-- "dekoriert"
		frame:SetWidth(118*(value-36000)/(56000-36000))
		frame:SetBackgroundColor(0.5, 2/3, 1, 0.5)	-- bluish
	elseif (value < 91000) then	-- "geschätzt"
		frame:SetWidth(118*(value-56000)/(91000-56000))
		frame:SetBackgroundColor(0, 1, 1, 0.5)		-- cyan
	elseif (value < 151000) then	-- "verehrt"
		frame:SetWidth(118*(value-91000)/(151000-91000))
		frame:SetBackgroundColor(0, 1, 1, 0.5)		-- blue/green
	else   				-- "verherrlicht"
		frame:SetWidth(118)
		frame:SetBackgroundColor(0, 1, 0, 0.5)		-- green
	end
end

function ToonInfo.BuildFactionWindow(context)
	if factionWindow then
		return
	end

	factionWindow=UI.CreateFrame("RiftWindow", "ToonInfo", context)
	factionWindow:SetTitle(L("Factions"))
	factionWindow:SetPoint("CENTER", UIParent, "CENTER", 0,0)
	factionWindow:SetWidth(440)
	factionWindow:SetBackgroundColor(0, 0, 0, 1)

	local closeButton = UI.CreateFrame("RiftButton", "ToonInfoCloseFactionButton", factionWindow)
	closeButton:SetSkin("close")
	closeButton:SetPoint("TOPRIGHT", factionWindow, "TOPRIGHT", -8, 15)
	function closeButton.Event:LeftPress()
		factionWindow:SetVisible(false)
	end

	local haveid={}
	local idlist={}
	for toon,data in pairs(ToonInfoShard) do
		if data["faction"] then
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
	row:SetPoint("TOPLEFT", factionWindow, "TOPLEFT", 20, 50)
	row:SetHeight(70)
	factionWindow.header=row

	row.toons={}

	n=1
	for toon, data in pairs(ToonInfoShard) do
		text=UI.CreateFrame("Text", "FactionRowHeader"..toon, row)
		text:SetPoint("TOPLEFT", row, "TOPLEFT", 250-120+n*120, 0)
		text:SetWidth(118)
		text:SetHeight(30)
		text:SetFontSize(16)
		text:SetText(toon)
		row.toons[toon]=text
		n=n+1
	end

	m=1
	for i,id in ipairs(idlist) do
		row=UI.CreateFrame("Frame", "FactionRow"..i, factionWindow);
		row:SetPoint("TOPLEFT", factionWindow, "TOPLEFT", 20, 50+m*30)
		row:SetHeight(30)
		factionWindow.factionrows[id]=row
		local icon
		local text
		local detail
		icon=UI.CreateFrame("Texture", "texture", row)
		icon:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
		icon:SetWidth(30)
		icon:SetHeight(30)
		text=UI.CreateFrame("Text", "text", row)
		text:SetPoint("TOPLEFT", row, "TOPLEFT", 32, 0)
		text:SetWidth(210)
		text:SetHeight(30)
		text:SetFontSize(16)
		detail=Inspect.Faction.Detail(id)
		if detail ~= nil then
			if detail.icon then icon:SetTexture("Rift", detail.icon) end
			if detail.name then text:SetText(detail.name) end
		else
			print("Inspect.Faction.Detail returns nil for "..id)
		end
		row.toons={}

		n=1
		for toon,data in pairs(ToonInfoShard) do
			local cell
			cell=UI.CreateFrame("Text", "text", row)
			cell:SetPoint("TOPLEFT", row, "TOPLEFT", 250-120+n*120, 0)
			cell:SetWidth(118)
			cell:SetHeight(25)
			cell:SetBackgroundColor(0, 0, 0, 1)
			cell:SetFontSize(20)
			row.toons[toon]=cell
			
			cell.bar=UI.CreateFrame("Frame", "text", cell)
			cell.bar:SetPoint("BOTTOMLEFT", cell, "BOTTOMLEFT", 0, 0)
			cell.bar:SetHeight(25)

			if data["faction"] and data["faction"][id] then
				cell:SetText(formatfaction(id, data["faction"][id]))
				setColorAndWidth(cell.bar, data["faction"][id])
			else
				cell:SetText("------")
				cell.bar:SetBackgroundColor(0, 0, 0, 0)
				cell.bar:SetWidth(0)
			end
			
			n=n+1
		end
		factionWindow.factionrows[id]=row
		m=m+1
	end

	factionWindow:SetHeight(80+m*30)
	factionWindow:SetWidth(250-120+n*120+40)
	factionWindow:SetVisible(false)
end

function ToonInfo.UpdateFactionWindow(toon, faction, value)
	if factionWindow 
	and factionWindow.factionrows[faction]
	and factionWindow.factionrows[faction].toons[toon] then
		factionWindow.factionrows[faction].toons[toon]:SetText(formatfaction(faction, value))
		setColorAndWidth(factionWindow.factionrows[faction].toons[toon].bar, value)
	end
end

function ToonInfo.ToggleFactionWindow()
	factionWindow:SetVisible(not factionWindow:GetVisible())
end
