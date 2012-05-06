local function L(x) return Translations.ToonInfo.L(x) end

local tooltipExtension
local lastTimeFrame=0

function ToonInfo.BuildTooltipExtension()
	tooltipExtension=UI.CreateFrame("Frame", "TooltipExtension", context)
	tooltipExtension:SetWidth(150)
	tooltipExtension:SetHeight(50)
	tooltipExtension:SetBackgroundColor(0.6, 0.6, 0.6, 0.8)
	tooltipExtension:SetVisible(false)
	tooltipExtension.textTotal=UI.CreateFrame("Text", "TotalText", tooltipExtension);
	tooltipExtension.textTotal:SetPoint("BOTTOMLEFT", tooltipExtension, "BOTTOMLEFT", 2, -2)
	tooltipExtension.textTotal:SetHeight(20)
	tooltipExtension.textTotal:SetFontSize(18)
	tooltipExtension.textTotal:SetWidth(130)
	tooltipExtension.textTotal:SetBackgroundColor(0, 0, 0, 1)
	tooltipExtension.textTotal:SetText(L("Total"))
	
	tooltipExtension.countTotal=UI.CreateFrame("Text", "TotalNumber", tooltipExtension);
	tooltipExtension.countTotal:SetPoint("BOTTOMRIGHT", tooltipExtension, "BOTTOMRIGHT", -2, -2)
	tooltipExtension.countTotal:SetHeight(20)
	tooltipExtension.countTotal:SetFontSize(18)
	tooltipExtension.countTotal:SetWidth(38)
	tooltipExtension.countTotal:SetBackgroundColor(0, 0, 0, 1)	
	tooltipExtension.countTotal:SetText("")
	
	tooltipExtension.nameList={}
	tooltipExtension.countList={}
	tooltipExtension.iconList={}
	
	-- dump(tooltipExtension:GetStrataList())
end

function ToonInfo.showTooltipExtension(itemname)
	local n=1
	local text, count 
	local total=0
	for toon, data in pairs(ToonInfoShard) do
		for slot, item in pairs(ToonInfoShard[toon]["slots"]) do
			if item and (item.name == itemname) then
				if not tooltipExtension.nameList[n] then
					tooltipExtension.nameList[n]=UI.CreateFrame("Text", "ExtensionText"..n, tooltipExtension);
					text=tooltipExtension.nameList[n]
					if (n==1) then
						text:SetPoint("TOPLEFT", tooltipExtension, "TOPLEFT", 2, 2)
					else
						text:SetPoint("TOPLEFT", tooltipExtension.nameList[n-1], "BOTTOMLEFT", 0, 0)
					end
					text:SetHeight(20)
					text:SetFontSize(18)
					text:SetWidth(110)
					text:SetBackgroundColor(0, 0, 0, 1)
					
					tooltipExtension.countList[n]=UI.CreateFrame("Text", "ExtensionNumber"..n, tooltipExtension);
					count=tooltipExtension.countList[n]
					if (n==1) then
						count:SetPoint("TOPRIGHT", tooltipExtension, "TOPRIGHT", -2, 2)
					else
						count:SetPoint("TOPRIGHT", tooltipExtension.countList[n-1], "BOTTOMRIGHT", 0, 0)
					end
					count:SetHeight(20)
					count:SetFontSize(18)
					count:SetWidth(38)
					count:SetBackgroundColor(0, 0, 0, 1)

					tooltipExtension.iconList[n]=UI.CreateFrame("Texture", "ExtensionTexture"..n, tooltipExtension);
					icon=tooltipExtension.iconList[n]
					icon:SetPoint("TOPRIGHT", count, "TOPLEFT", 0, 0)
					icon:SetHeight(20)
					icon:SetWidth(20)
					icon:SetBackgroundColor(0, 0, 0, 1)
				else
					text=tooltipExtension.nameList[n]
					count=tooltipExtension.countList[n]
					icon=tooltipExtension.iconList[n]
				end

				if (slot:sub(1,4) == "sibg") or (slot:sub(1,4) == "sbbg") then
					icon:SetTexture("ToonInfo", "box.png")
				elseif (slot:sub(1,4) == "seqp") then
					icon:SetTexture("ToonInfo", "user.png")	
				elseif slot:sub(1,2) == "sw" then 
					icon:SetTexture("ToonInfo", "wardrobe.png")
				elseif slot:sub(1,2) == "si" then 
					icon:SetTexture("ToonInfo", "backpack.png")
				elseif (slot:sub(1,2) == "sb") or (slot:sub(1,2) == "sg") then 
					icon:SetTexture("ToonInfo", "chest.png")
				else
					icon:SetTexture("ToonInfo", "qmark.png")
				end
				
				text:SetText(toon)
				count:SetText(""..(item.stack or "1"))
				text:SetVisible(true)
				count:SetVisible(true)
				icon:SetVisible(true)
				n=n+1
				total=total + (item.stack or 1)
			end
		end
	end
	tooltipExtension:ClearAll()
	tooltipExtension:SetWidth(170)
	tooltipExtension:SetHeight(n*20+6)
	while tooltipExtension.nameList[n] ~= nil do
		tooltipExtension.nameList[n]:SetVisible(false)
		tooltipExtension.countList[n]:SetVisible(false)
		tooltipExtension.iconList[n]:SetVisible(false)
		n=n+1
	end
	tooltipExtension.countTotal:SetText(""..total)
	tooltipExtension:SetVisible(true)
-- I'd like to move "my" window to the top, but unfortunately that doesn't work,
--	tooltipExtension:SetPoint("TOPRIGHT", UI.Native.Tooltip, "TOPLEFT", -2, 0)
--	tooltipExtension:SetStrata(UI.Native.Tooltip:GetStrata())
-- so we show the additional tooltip next to the "Tooninfo" window hoping it won't
-- get hidden there.
	local l=ToonInfo.GetMiniWindowLeft()
	local t=ToonInfo.GetMiniWindowTop()

	if (l>500 and t>400) then
		tooltipExtension:SetPoint("BOTTOMRIGHT", ToonInfo.GetMiniWindow(), "BOTTOMLEFT", -5, 0)
	elseif (l>500 and t<=400) then
		tooltipExtension:SetPoint("TOPRIGHT", ToonInfo.GetMiniWindow(), "TOPLEFT", -5, 0)
	elseif (l<=500 and t>400) then
		tooltipExtension:SetPoint("BOTTOMLEFT", ToonInfo.GetMiniWindow(), "BOTTOMRIGHT", -5, 0)
	else
		tooltipExtension:SetPoint("TOPLEFT", ToonInfo.GetMiniWindow(), "TOPRIGHT", 5, 0)
	end
	
--	lastTimeFrame=Inspect.Time.Frame()
--	print ("Set Frame "..lastTimeFrame)
end

-- There is an api "bug" that i don't really know how to work around:
-- if the mouse is moved over a wearable item, you get the additional
-- "item you are wearing" tooltip. This sends a few "type nil" messages
-- that normally mean "tooltip gets hidden". So the item count tooltip
-- gets hidden here as well. Since the "check time frame" trick doesn't
-- seem to work either, i can't do much about that now.

function ToonInfo.hideTooltipExtension()
--	local f=Inspect.Time.Frame()
--	if f ~= lastTimeFrame then
--		print ("f="..f..", lastFrame="..lastTimeFrame)
		tooltipExtension:SetVisible(false)
--	end
end
