-- User Interface

local function L(x) return Translations.ToonInfo.L(x) end

local miniWindow
local itemResultWindow
local context

local function buildItemResultWindow()
	itemResultWindow=ToonInfo.CreateScrollableRiftWindow("ToonInfo", L("Found Items"), context)
	itemResultWindow:SetWidth(600)
	itemResultWindow.toonWindow = {}
end

local function resetItemResultWindow()
	-- itemResultWindow.scrollView:SetPoint("TOPLEFT", itemResultWindow, "TOPLEFT", 20, 20)
	for toon, tw in pairs(itemResultWindow.toonWindow) do
		tw.childcount=0
		tw:SetHeight(0)
		tw:SetVisible(false)
		tw.name:SetPoint("TOPLEFT", tw, "TOPLEFT", 2, 2)
		for i,fr in ipairs(tw.children) do
			fr:SetVisible(false)
		end
	end
end

function ToonInfo.BagNameforPlace(placename)
	local slot=placename:sub(1, 4)
	if (slot == "sibg") or (slot == "sbbg") then
		return "box"
	elseif (slot == "seqp") then
		return "user"
	end
	
	slot=slot:sub(1,2)
	if slot == "sw" then 
		return "wardrobe"
	elseif slot == "si" then 
		return "backpack"
	elseif (slot == "sb") or (slot == "sg") then 
		return "chest"
	end
	
	return "qmark"
end

local function addItemResultWindow(toon, slot, item)
	local tw
	local fr
	local count
	local bagtype = ToonInfo.BagNameforPlace(slot)

	if not itemResultWindow.toonWindow[toon] then
		itemResultWindow.toonWindow[toon] = UI.CreateFrame("Frame", "ToonInfo", itemResultWindow)
		if not itemResultWindow.bottomToonWindow then
			itemResultWindow.toonWindow[toon]:SetPoint("TOPLEFT", itemResultWindow, "TOPLEFT", 0, 0)
		else
			itemResultWindow.toonWindow[toon]:SetPoint("TOPLEFT", itemResultWindow.bottomToonWindow, "BOTTOMLEFT", 0, 0)
		end
		tw=itemResultWindow.toonWindow[toon]
		tw:SetWidth(600);
		tw.name = UI.CreateFrame("Text", "text", itemResultWindow.toonWindow[toon])
		tw.name:SetBackgroundColor(0.5, 0.5, 0.8, 1)
		tw.name:SetText(toon)
		tw.name:SetPoint("TOPLEFT", tw, "TOPLEFT", 2, 2)
		tw.name:SetWidth(600);
		tw.name:SetFontSize(20)
		tw.childcount=0
		tw.children={}
		itemResultWindow.bottomToonWindow=tw
	else
		tw=itemResultWindow.toonWindow[toon]
	end
	
	local mergestring
	if not ToonInfoChar.merge then ToonInfoChar.merge = 0; end
	if ToonInfoChar.merge <= 1 then
		mergestring = bagtype .. ":" .. item.name
	elseif ToonInfoChar.merge == 2 then
		mergestring = item.name
	end
	
	count=tw.childcount
	if ToonInfoChar.merge > 0 then
		for i = 1, count, 1 do
			if tw.children[i].mergestring == mergestring then
				tw.children[i].mergecount = tw.children[i].mergecount + (item.stack or 1)
				tw.children[i].mergenum = tw.children[i].mergenum + 1
				tw.children[i].count:SetText(tw.children[i].mergenum .. "/" .. tw.children[i].mergecount)
				if ToonInfoChar.merge >= 2 then
					tw.children[i].bag:SetTexture("ToonInfo", "merge.png")
				end
				return
			end
		end
	end
	
	if not tw.children[count+1] then
		fr=UI.CreateFrame("Frame", "ToonInfo", tw)
		fr:SetWidth(600)
		fr:SetHeight(32)
		tw.children[count+1]=fr
		
		fr.bag = UI.CreateFrame("Texture", "bag", fr)
		fr.bag:SetWidth(32)
		fr.bag:SetHeight(32)
		fr.bag:SetPoint("TOPLEFT", fr, "TOPLEFT", 0, 0)
		fr.icon = UI.CreateFrame("Texture", "itembtn", fr)
		fr.icon:SetWidth(32)
		fr.icon:SetHeight(32)
		fr.icon:SetPoint("TOPLEFT", fr, "TOPLEFT", 32, 0)
		fr.count = UI.CreateFrame("Text", "text", fr)
		fr.count:SetWidth(56)		
		fr.count:SetPoint("TOPLEFT", fr, "TOPLEFT", 64, 0)
		fr.count:SetFontSize(20)
		fr.label = UI.CreateFrame("Text", "text", fr)
		fr.label:SetWidth(480)
		fr.label:SetPoint("TOPLEFT", fr, "TOPLEFT", 120, 0)
	else
		fr=tw.children[count+1]
	end
	str=item.name
	if item.flavor then str=str .. " - " .. item.flavor end
	if item.description then str=str .. "\n" .. item.description end
	fr.label:SetText(str)
	fr.icon:SetTexture("Rift", item.icon)
	fr.bag:SetTexture("ToonInfo", bagtype .. ".png")
	if item.stack then
		fr.count:SetText("" .. item.stack)
	else
		fr.count:SetText("")
	end
	fr.mergestring = mergestring
	fr.mergecount = (item.stack or 1)
	fr.mergenum = 1
	
	fr:SetVisible(true)
	tw.childcount = count+1
	tw:SetHeight((tw.childcount+1)*32)
	tw:SetVisible(true)
end

local function sortSearchResults(toon)
	local i, w
	
	if not itemResultWindow.toonWindow[toon] then return end
	local tw=itemResultWindow.toonWindow[toon]
	if tw.childcount==0 then return end
	
	-- print(toon .. ": hat "..table.getn(tw.children).." Einträge, davon "..tw.childcount.."benutzt.")

	if table.getn(tw.children) > tw.childcount then
		for i=tw.childcount+1, table.getn(tw.children) do
			-- print("i="..i)
			tw.children[i].mergestring='~~~'
		end
	end
	table.sort(tw.children,
		function(a, b) return a.mergestring < b.mergestring end
	)
	local nused=0
	for i, w in ipairs(tw.children) do
		-- print ("Zeile "..i.."hat Mergestring "..w.mergestring)
		w:SetPoint("TOPLEFT", tw, "TOPLEFT", 0, i*32)
	end
end

local function showItemResultWindow()
	local neededHeight=0
	local i,w
	for i, w in pairs(itemResultWindow.toonWindow) do
		neededHeight=neededHeight+w:GetHeight()
	end
	itemResultWindow:SetHeight(neededHeight)
	itemResultWindow:SetVisible(true)
end

local function findItems(filter)
	if filter:len() < 3 then	-- prevent huge content list
		return
	end
	if not itemResultWindow then
		buildItemResultWindow()
	end
	resetItemResultWindow()
	for toon, data in pairs(ToonInfoShard) do
		for slot, item in pairs(ToonInfoShard[toon]["slots"]) do
			if item
			and (string.find(item.name:lower(), filter)
			    or (item.flavor and string.find(item.flavor:lower(), filter))
			    or (item.description and string.find(item.description:lower(), filter))
			) then
				str=toon .. ": " .. slot ..  " " .. item.name
				if (item.stack and item.stackMax) then
					str = str .. " (" .. item.stack .. "/" ..item.stackMax .. ")"
				end
				-- print (str);
				addItemResultWindow(toon, slot, item)
			end
		end
		sortSearchResults(toon)
	end
	showItemResultWindow()
end

function ToonInfo.BuildMiniWindow()
	miniWindow=UI.CreateFrame("Frame", "ToonInfo", context)
	miniWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", ToonInfoChar.xpos, ToonInfoChar.ypos)
	miniWindow:SetWidth(150)
	miniWindow:SetHeight(50)
	miniWindow:SetBackgroundColor(0.1, 0.1, 0.1, 0.8)
	miniWindow:SetVisible(true)
	miniWindow.state={}
	function miniWindow.Event:LeftDown()
		miniWindow.state.mouseDown = true
		local mouse = Inspect.Mouse()
		miniWindow.state.startX = miniWindow:GetLeft()
		miniWindow.state.startY = miniWindow:GetTop()
		miniWindow.state.mouseStartX = mouse.x
		miniWindow.state.mouseStartY = mouse.y
		miniWindow:SetBackgroundColor(0.4, 0.4, 0.4, 0.8)
	end

	function miniWindow.Event:MouseMove()
		if miniWindow.state.mouseDown then
			local mouse = Inspect.Mouse()
			ToonInfoChar.xpos=mouse.x - miniWindow.state.mouseStartX + miniWindow.state.startX
			ToonInfoChar.ypos=mouse.y - miniWindow.state.mouseStartY + miniWindow.state.startY
			miniWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT",
				ToonInfoChar.xpos, ToonInfoChar.ypos)
		end
	end

	function miniWindow.Event:LeftUp()
		if miniWindow.state.mouseDown then
			miniWindow.state.mouseDown = false
			miniWindow:SetBackgroundColor(0.1, 0.1, 0.1, 0.8)
		end
	end
	
	miniWindow.title = UI.CreateFrame("Text", "text", miniWindow)
	miniWindow.title:SetText(L("ToonInfo"))
	miniWindow.title:SetPoint("TOPLEFT", miniWindow, "TOPLEFT", 2, 2)
	miniWindow:SetWidth(146);

	miniWindow.itembtn = UI.CreateFrame("Texture", "itembtn", miniWindow)
	miniWindow.itembtn:SetPoint("TOPRIGHT", miniWindow, "TOPRIGHT", -2, 2)
	miniWindow.itembtn:SetWidth(22)
	miniWindow.itembtn:SetHeight(22)
--	miniWindow.itembtn:SetBackgroundColor(0.1, 0.1, 0.5)
	miniWindow.itembtn:SetTexture("ToonInfo", "paperbag.png")

	miniWindow.moneybtn = UI.CreateFrame("Texture", "moneybtn", miniWindow)
	miniWindow.moneybtn:SetPoint("TOPRIGHT", miniWindow.itembtn, "TOPLEFT", -2, 0)
	miniWindow.moneybtn:SetWidth(22)
	miniWindow.moneybtn:SetHeight(22)
--	miniWindow.moneybtn:SetBackgroundColor(0.1, 0.1, 0.5)
	miniWindow.moneybtn:SetTexture("ToonInfo", "money.png")
	function miniWindow.moneybtn.Event:LeftClick()
		ToonInfo.BuildMoneyWindow(context)
		ToonInfo.ToggleMoneyWindow()
	end

	miniWindow.factionbtn = UI.CreateFrame("Texture", "factionbtn", miniWindow)
	miniWindow.factionbtn:SetPoint("TOPRIGHT", miniWindow.moneybtn, "TOPLEFT", -2, 0)
	miniWindow.factionbtn:SetWidth(22)
	miniWindow.factionbtn:SetHeight(22)
--	miniWindow.factionbtn:SetBackgroundColor(0.1, 0.1, 0.5)
	miniWindow.factionbtn:SetTexture("ToonInfo", "heart.png")
	function miniWindow.factionbtn.Event:LeftClick()
		ToonInfo.BuildFactionWindow(context)
		ToonInfo.ToggleFactionWindow()
	end
	
	miniWindow.filter = UI.CreateFrame("RiftTextfield", "textField", miniWindow)
	miniWindow.filter:SetPoint("TOPLEFT", miniWindow.title, "BOTTOMLEFT", 0, 2)
	miniWindow.filter:SetBackgroundColor(0.1, 0.1, 0.5)
	miniWindow.filter:SetWidth(100)
	miniWindow.filter:SetText("")
	function miniWindow.filter.Event:KeyType(key)
		if key == "\r" then
			local filter = miniWindow.filter:GetText():lower()
			findItems(filter)
			miniWindow.filter:SetKeyFocus(false)
		end
	end
	
	miniWindow.searchbtn = UI.CreateFrame("Texture", "searchbtn", miniWindow)
	miniWindow.searchbtn:SetPoint("TOPRIGHT", miniWindow.itembtn, "BOTTOMRIGHT", 0, 2)
	miniWindow.searchbtn:SetWidth(22)
	miniWindow.searchbtn:SetHeight(22)
--	miniWindow.searchbtn:SetBackgroundColor(0.1, 0.1, 0.5)
	miniWindow.searchbtn:SetTexture("ToonInfo", "find.png")
	function miniWindow.searchbtn.Event:LeftClick()
		local filter = miniWindow.filter:GetText():lower()
		findItems(filter)
		miniWindow.filter:SetKeyFocus(false)
	end
end

function ToonInfo.GetMiniWindow()
	return miniWindow
end

function ToonInfo.GetMiniWindowLeft()
	return miniWindow:GetLeft()
end

function ToonInfo.GetMiniWindowTop()
	return miniWindow:GetTop()
end

function ToonInfo.createUI()
	context=UI.CreateContext("ToonInfo")
	-- context:SetSecureMode("restricted")
	
	if (miniWindow == nil) then
		if not ToonInfoChar.xpos then ToonInfoChar.xpos=100 end
		if not ToonInfoChar.ypos then ToonInfoChar.ypos=100 end
		ToonInfo.BuildMiniWindow()
		ToonInfo.BuildTooltipExtension(context)
	end
end

function ToonInfo.rebuildAllWindows()
		if (itemResultWindow) then
			itemResultWindow:SetVisible(false)
			itemResultWindow = nil
		end
		ToonInfo.forgetMoneyWindow()
		ToonInfo.forgetFactionWindow()
end
