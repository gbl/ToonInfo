local function L(x) return Translations.ToonInfo.L(x) end

local moneyWindow

local function formatcurrency(name, amount)
	if name == "coin" then
		local plat=math.floor(amount/10000)
		local gold=(math.floor(amount/100))%100
		local silver=amount%100
		return plat .. ", " .. gold .. ", " .. silver
	else
		return ""..amount
	end
end

function ToonInfo.BuildMoneyWindow(context)
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
	moneyWindow.currencyrows={}
	local n=1, m
	local row
	row=UI.CreateFrame("Frame", "MoneyRowHeader", moneyWindow);
	row:SetPoint("TOPLEFT", moneyWindow, "TOPLEFT", 20, 50)
	row:SetHeight(70)
	moneyWindow.header=row

	row.toons={}

	n=1
	for toon, data in pairs(ToonInfoShard) do
		text=UI.CreateFrame("Text", "MoneyRowHeader"..toon, row)
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
		row=UI.CreateFrame("Frame", "MoneyRow"..i, moneyWindow);
		row:SetPoint("TOPLEFT", moneyWindow, "TOPLEFT", 20, 50+m*30)
		row:SetHeight(30)
		moneyWindow.currencyrows[id]=row
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
		detail=Inspect.Currency.Detail(id)
		if detail ~= nil then
			if detail.icon then icon:SetTexture("Rift", detail.icon) end
			if detail.name then text:SetText(detail.name) end
		else
			print("Inspect.Currency.Detail returns nil for "..id)
		end
		row.toons={}

		n=1
		for toon,data in pairs(ToonInfoShard) do
			local cell
			cell=UI.CreateFrame("Text", "text", row)
			cell:SetPoint("TOPLEFT", row, "TOPLEFT", 250-120+n*120, 0)
			cell:SetWidth(118)
			cell:SetBackgroundColor(0, 0, 0, 1)
			if data["money"] and data["money"][id] then
				local content=formatcurrency(id, data["money"][id])
				cell:SetText(content)
			else
				cell:SetText("------")
			end
			cell:SetFontSize(20)
			row.toons[toon]=cell
			n=n+1
		end
		moneyWindow.currencyrows[id]=row
		m=m+1
	end

	moneyWindow:SetHeight(80+m*30)
	moneyWindow:SetWidth(250-120+n*120+40)
	moneyWindow:SetVisible(false)
end

function ToonInfo.UpdateMoneyWindow(toon, currency, value)
	if moneyWindow then
		moneyWindow.currencyrows[currency].toons[toon]:SetText(formatcurrency(currency, value))
		moneyWindow.currencyrows[currency].toons[toon]:SetBackgroundColor(0.3, 0.3, 0, 1)
	end
end

function ToonInfo.ToggleMoneyWindow()
	moneyWindow:SetVisible(not moneyWindow:GetVisible())
end
