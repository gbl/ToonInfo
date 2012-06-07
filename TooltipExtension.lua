local function L(x) return Translations.ToonInfo.L(x) end

local tooltipExtension
local lastTimeFrame=0

function ToonInfo.BuildTooltipExtension(context)
	tooltipExtension=UI.CreateFrame("Frame", "TooltipExtension", context)
	tooltipExtension:SetWidth(150)
	tooltipExtension:SetHeight(50)
	tooltipExtension:SetBackgroundColor(0.6, 0.6, 0.6, 0.8)
	tooltipExtension:SetVisible(false)
	tooltipExtension.textTotal=UI.CreateFrame("Text", "TotalText", tooltipExtension);
	tooltipExtension.textTotal:SetPoint("BOTTOMLEFT", tooltipExtension, "BOTTOMLEFT", 2, -2)
	tooltipExtension.textTotal:SetHeight(20)
	tooltipExtension.textTotal:SetFontSize(16)
	tooltipExtension.textTotal:SetWidth(130)
	tooltipExtension.textTotal:SetBackgroundColor(0, 0, 0, 1)
	tooltipExtension.textTotal:SetText(L("Total"))
	
	tooltipExtension.countTotal=UI.CreateFrame("Text", "TotalNumber", tooltipExtension);
	tooltipExtension.countTotal:SetPoint("BOTTOMRIGHT", tooltipExtension, "BOTTOMRIGHT", -2, -2)
	tooltipExtension.countTotal:SetHeight(20)
	tooltipExtension.countTotal:SetFontSize(16)
	tooltipExtension.countTotal:SetWidth(38)
	tooltipExtension.countTotal:SetBackgroundColor(0, 0, 0, 1)	
	tooltipExtension.countTotal:SetText("")
	
	tooltipExtension.nameList={}
	tooltipExtension.countList={}
	tooltipExtension.iconList={}
	tooltipExtension.nitems={}
	
	-- dump(tooltipExtension:GetStrataList())
end

function ToonInfo.showTooltipExtension(itemname)
	local n=1
	local text, count, icon
	local total=0
	local windowToAttachTo = ToonInfo.GetMiniWindow()
	if ToonInfoChar.attachToTooltip == true then
		windowToAttachTo = UI.Native.Tooltip
	end
	local comparestring
	for toon, data in pairs(ToonInfoShard) do
		local presentmap={}
		for slot, item in pairs(ToonInfoShard[toon]["slots"]) do
			if item and (item.name == itemname) then
				local bagtype = ToonInfo.BagNameforPlace(slot)
				local mergestring
				if not ToonInfoChar.merge then ToonInfoChar.merge = 0; end
				if ToonInfoChar.merge <= 1 then
					mergestring = bagtype .. ":" .. item.name
				elseif ToonInfoChar.merge == 2 then
					mergestring = item.name
				end
				
				if (ToonInfoChar.merge>=1) and (presentmap[mergestring]) then
					local pos=presentmap[mergestring]
					local nitems
					text=tooltipExtension.nameList[pos]
					count=tooltipExtension.countList[pos]
					icon=tooltipExtension.iconList[pos]
					nitems=tooltipExtension.nitems[pos]
					nitems=nitems + (item.stack or 1)
					count:SetText(""..nitems)
					tooltipExtension.nitems[pos]=nitems
					if ToonInfoChar.merge >= 2 then
						icon:SetTexture("ToonInfo", "merge.png")
					end
				else
					if not tooltipExtension.nameList[n] then
						tooltipExtension.nameList[n]=UI.CreateFrame("Text", "ExtensionText"..n, tooltipExtension);
						text=tooltipExtension.nameList[n]
						if (n==1) then
							text:SetPoint("TOPLEFT", tooltipExtension, "TOPLEFT", 2, 2)
						else
							text:SetPoint("TOPLEFT", tooltipExtension.nameList[n-1], "BOTTOMLEFT", 0, 0)
						end
						text:SetHeight(20)
						text:SetFontSize(16)
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
						count:SetFontSize(16)
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

					icon:SetTexture("ToonInfo", bagtype .. ".png")
					
					text:SetText(toon)
					count:SetText(""..(item.stack or "1"))
					text:SetVisible(true)
					count:SetVisible(true)
					icon:SetVisible(true)
					presentmap[mergestring]=n
					tooltipExtension.nitems[n]=(item.stack or 1)
					n=n+1
					total=total + (item.stack or 1)
				end -- not already present
			end -- item matches
		end -- slot loop
	end -- toon loop
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
	tooltipExtension:SetLayer(UI.Native.Tooltip:GetLayer())
-- so we show the additional tooltip next to the "Tooninfo" window hoping it won't
-- get hidden there.
	local l=windowToAttachTo:GetLeft()
	local t=windowToAttachTo:GetTop()
	
	-- print("l="..l..", t="..t)

	local ap = ToonInfoChar.attachPosition or "auto"
	if (ap == "leftup" or (ap == "auto" and l>500 and t>400)) then
		tooltipExtension:SetPoint("BOTTOMRIGHT", windowToAttachTo, "BOTTOMLEFT", -5, 0)
	elseif (ap == "leftdown" or (ap == "auto" and l>500 and t<=400)) then
		tooltipExtension:SetPoint("TOPRIGHT", windowToAttachTo, "TOPLEFT", -5, 0)
	elseif (ap == "rightup" or (ap == "auto" and l<=500 and t>400)) then
		tooltipExtension:SetPoint("BOTTOMLEFT", windowToAttachTo, "BOTTOMRIGHT", -5, 0)
	elseif (ap=="left") then
		tooltipExtension:SetPoint("CENTERRIGHT", windowToAttachTo, "CENTERLEFT", -5, 0)
	elseif (ap=="right") then
		tooltipExtension:SetPoint("CENTERLEFT", windowToAttachTo, "CENTERRIGHT", -5, 0)
	elseif (ap=="top") then
		tooltipExtension:SetPoint("BOTTOMCENTER", windowToAttachTo, "TOPCENTER", -5, 0)
	elseif (ap=="bottom") then
		tooltipExtension:SetPoint("TOPCENTER", windowToAttachTo, "BOTTOMCENTER", -5, 0)
	else
		tooltipExtension:SetPoint("TOPLEFT", windowToAttachTo, "TOPRIGHT", 5, 0)
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
