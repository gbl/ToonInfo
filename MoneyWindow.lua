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

	moneyWindow=ToonInfo.CreateScrollableRiftWindow("MoneyWindow", L("Currencies"), context)

	local nameforid={}
	local idlist={}
	local toon, data
	local id, amount, name, detail
	local i, n, m
	local row, lastcatname, catname

	for toon,data in pairs(ToonInfoShard) do
		if (data["money"] ~= nil) and (data["guild"] ~= true) then
			for id, amount in pairs(data["money"]) do
				if not nameforid[id] then
					detail=Inspect.Currency.Detail(id)
					if detail ~= nil then
						if detail.icon then
							ToonInfoGlobal["currencyicon"][id]=detail.icon
						end
						if detail.name then
							ToonInfoGlobal["currencyname"][id]=detail.name
						end
						if detail.category then
							-- print ("category for "..id.."is "..detail.category)
							local category=Inspect.Currency.Category.Detail(detail.category)
							ToonInfoGlobal["currencycategory"][id]=category.name
						end
					end
					name=(ToonInfoGlobal["currencyname"][id] or "???")
					catname=(ToonInfoGlobal["currencycategory"][id] or "???")
					nameforid[id]=catname .. "|" .. name
					table.insert(idlist, id)
				end
			end
		end
	end
	table.sort(idlist, function(a,b) return nameforid[a]<nameforid[b] end)
	moneyWindow.currencyrows={}

	row=UI.CreateFrame("Frame", "MoneyRowHeader", moneyWindow);
	row:SetPoint("TOPLEFT", moneyWindow, "TOPLEFT", 0, 0)
	row:SetHeight(70)
	moneyWindow.header=row

	row.toons={}

	n=1
	for toon, data in pairs(ToonInfoShard) do
		if (data["money"] ~= nil) and (data["guild"] ~= true) then
			text=UI.CreateFrame("Text", "MoneyRowHeader"..toon, row)
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
	lastcatname=""
	for i,id in ipairs(idlist) do
		if ToonInfoGlobal["currencycategory"][id] ~= lastcatname then
			lastcatname=(ToonInfoGlobal["currencycategory"][id] or "???")
			row=UI.CreateFrame("Text", "MoneyHeader"..lastcatname, moneyWindow)
			row:SetPoint("TOPLEFT", moneyWindow, "TOPLEFT", 0, 10+m*30)
			row:SetHeight(30)
			row:SetWidth(250-120+n*120)
			row:SetFontSize(16)
			row:SetBackgroundColor(0.5, 0.5, 0.8, 1)
			row:SetText(lastcatname)
			m=m+1
		end
		row=UI.CreateFrame("Frame", "MoneyRow"..id, moneyWindow);
		row:SetPoint("TOPLEFT", moneyWindow, "TOPLEFT", 0, 10+m*30)
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

		if ToonInfoGlobal["currencyicon"][id] ~= nil then
			icon:SetTexture("Rift", ToonInfoGlobal["currencyicon"][id])
		end
		if ToonInfoGlobal["currencyname"][id] ~= nil then
			text:SetText(ToonInfoGlobal["currencyname"][id])
		end

		row.toons={}

		n=1
		for toon,data in pairs(ToonInfoShard) do
			if (data["money"] ~= nil) and (data["guild"] ~= true) then
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
		end
		moneyWindow.currencyrows[id]=row
		m=m+1
	end

	moneyWindow:SetHeight(10+m*30)
	moneyWindow:SetWidth(250-120+n*120)
	moneyWindow:SetVisible(false)
end

function ToonInfo.UpdateMoneyWindow(toon, currency, value)
	if moneyWindow and moneyWindow.currencyrows[currency] and moneyWindow.currencyrows[currency].toons[toon] then
		moneyWindow.currencyrows[currency].toons[toon]:SetText(formatcurrency(currency, value))
		moneyWindow.currencyrows[currency].toons[toon]:SetBackgroundColor(0.3, 0.3, 0, 1)
	end
end

function ToonInfo.ToggleMoneyWindow()
	moneyWindow:SetVisible(not moneyWindow:GetVisible())
end

function ToonInfo.forgetMoneyWindow()
	if moneyWindow then
		moneyWindow:SetVisible(false)
		moneyWindow=nil
	end
end
