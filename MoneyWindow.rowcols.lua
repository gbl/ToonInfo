local function L(x) return Translations.ToonInfo.L(x) end

local moneyWindow

function ToonInfo.BuildMoneyWindow()
	if moneyWindow then
		return
	end

	moneyWindow=UI.CreateFrame("RiftWindow", "ToonInfo", context)
	moneyWindow:SetTitle(L("Currencies"))
	moneyWindow:SetPoint("CENTER", UIParent, "CENTER", 0,0)
	moneyWindow:SetWidth(440)
	moneyWindow:SetBackgroundColor(0, 0, 0, 1)

	local closeButton = UI.CreateFrame("RiftButton", "ToonInfoCloseButton", moneyWindow)
	closeButton:SetSkin("close")
	closeButton:SetPoint("TOPRIGHT", moneyWindow, "TOPRIGHT", -8, 15)
	function closeButton.Event:LeftPress()
		moneyWindow:SetVisible(false)
	end

	local haveid={}
	local idlist={}
	for toon,data in pairs(ToonInfoShard) do
		if data["money"] then
			for id, amount in pairs(data["money"]) do
				if not haveid[id] then
					haveid[id]=true
					table.insert(idlist, id)
				end
			end
		end
	end
	table.sort(idlist)
	moneyWindow.toonrows={}
	local n=1, m
	local row
	row=UI.CreateFrame("Frame", "MoneyRowHeader", moneyWindow);
	row:SetPoint("TOPLEFT", moneyWindow, "TOPLEFT", 20, 50)
	row:SetHeight(70)
	moneyWindow.header=row

	row.currencies={}
	
	m=0
	for i,id in ipairs(idlist) do
		local icon
		local text
		local detail
		icon=UI.CreateFrame("Texture", "texture", row)
		icon:SetPoint("TOPLEFT", row, "TOPLEFT", 150-80+i*80+25, 0)
		icon:SetWidth(40)
		icon:SetHeight(40)
--		cell:SetBackgroundColor(0, 0, 0, 1)
		text=UI.CreateFrame("Text", "text", row)
		text:SetPoint("TOPLEFT", row, "TOPLEFT", 150-80+i*80, 40)
		text:SetWidth(80)
		text:SetHeight(30)
		text:SetFontSize(16)
		detail=Inspect.Currency.Detail(id)
		if detail ~= nil then
			if detail.icon then icon:SetTexture("Rift", detail.icon) end
			if detail.name then text:SetText(detail.name) end
		else
			print("Inspect.Currency.Detail returns nil for "..id)
		end
		row.currencies[id]=cell
		m=m+1
	end

	for toon,data in pairs(ToonInfoShard) do
		row=UI.CreateFrame("Frame", "MoneyRow"..toon, moneyWindow);
		row:SetPoint("TOPLEFT", moneyWindow, "TOPLEFT", 20, 90+n*30)
		row:SetHeight(30)
		moneyWindow.toonrows[toon]=row

		row.name=UI.CreateFrame("Text", "text", row)
		row.name:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
		row.name:SetWidth(147)
		row.name:SetText(toon)
		row.name:SetFontSize(20)
		row.name:SetBackgroundColor(0, 0, 0, 1)
		row.currencies={}
		
		for i,id in ipairs(idlist) do
			local cell
			cell=UI.CreateFrame("Text", "text", row)
			cell:SetPoint("TOPLEFT", row, "TOPLEFT", 150-80+i*80, 0)
			cell:SetWidth(78)
			cell:SetBackgroundColor(0, 0, 0, 1)
			if data["money"] and data["money"][id] then
				cell:SetText(("         "..data["money"][id]):sub(-6))
			else
				cell:SetText("------")
			end
			cell:SetFontSize(20)
			row.currencies[id]=cell
		end
		n=n+1
	end
	moneyWindow:SetHeight(110+n*30)
	moneyWindow:SetWidth(40+150+m*80)
	moneyWindow:SetVisible(false)
end

function ToonInfo.UpdateMoneyWindow(toon, currency, value)
	if moneyWindow then
		moneyWindow.toonrows[toon].currencies[currency]:SetText(("        "..value):sub(-6))
		moneyWindow.toonrows[toon].currencies[currency]:SetBackgroundColor(0.3, 0.3, 0, 1)
	end
end

function ToonInfo.ToggleMoneyWindow()
	moneyWindow:SetVisible(not moneyWindow:GetVisible())
end
