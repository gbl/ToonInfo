-- User Interface

local function L(x) return Translations.ToonInfo.L(x) end

local miniWindow
local itemResultWindow
local context

local function buildItemResultWindow()
	itemResultWindow=UI.CreateFrame("RiftWindow", "ToonInfo", context)
	itemResultWindow:SetTitle(L("Found Items"))
	itemResultWindow:SetPoint("CENTER", UIParent, "CENTER", 0,0)
	itemResultWindow:SetWidth(440)
	itemResultWindow:SetBackgroundColor(0, 0, 0, 1)

	local closeButton = UI.CreateFrame("RiftButton", "ToonInfoCloseButton", itemResultWindow)
	closeButton:SetSkin("close")
	closeButton:SetPoint("TOPRIGHT", itemResultWindow, "TOPRIGHT", -8, 15)
	function closeButton.Event:LeftPress()
		itemResultWindow:SetVisible(false)
	end
	
	itemResultWindow.mask=UI.CreateFrame("Mask", "ToonInfoScrollMask", itemResultWindow)
	itemResultWindow.mask:SetPoint("TOPLEFT", itemResultWindow, "TOPLEFT", 20, 60)
	itemResultWindow.mask:SetPoint("BOTTOMRIGHT", itemResultWindow, "BOTTOMRIGHT", -20, -20)
--	itemResultWindow.mask:SetBackgroundColor(0.5, 0, 0.5, 0.5)	

	itemResultWindow.scrollView=UI.CreateFrame("Frame", "ToonInfoScrollview", itemResultWindow.mask)
	itemResultWindow.scrollView:SetPoint("TOPLEFT", itemResultWindow, "TOPLEFT", 20, 60)
	itemResultWindow.scrollView:SetPoint("BOTTOMRIGHT", itemResultWindow, "BOTTOMRIGHT", -40, -20)
	
	itemResultWindow.scrollbar = UI.CreateFrame("RiftScrollbar", "ToonInfoScrollbar", itemResultWindow)
	itemResultWindow.scrollbar:SetOrientation("vertical")
	itemResultWindow.scrollbar:SetPoint("TOPRIGHT", itemResultWindow, "TOPRIGHT", -20, 60)
	itemResultWindow.scrollbar:SetPoint("BOTTOMRIGHT", itemResultWindow, "BOTTOMRIGHT", -20, -20)
	itemResultWindow.scrollbar:SetVisible(true)
	itemResultWindow.scrollbar.Event.ScrollbarChange = function()
		local position=itemResultWindow.scrollbar:GetPosition()
		itemResultWindow.scrollView:SetPoint("TOPLEFT", itemResultWindow, "TOPLEFT", 20, 60-position)
	end

	itemResultWindow:SetVisible(false)
	itemResultWindow.toonWindow = {}
end

local function resetItemResultWindow()
	itemResultWindow.scrollView:SetPoint("TOPLEFT", itemResultWindow, "TOPLEFT", 20, 60)
	for toon, tw in pairs(itemResultWindow.toonWindow) do
		tw.childcount=0
		tw:SetHeight(0)
		tw:SetVisible(false)
		tw.name:SetPoint("TOPLEFT", tw, "TOPLEFT", 2, 2)
		for i,fr in ipairs(tw.children) do
			fr:SetVisible(false)
		end
	end
	itemResultWindow.neededHeight=0
end

local function addItemResultWindow(toon, slot, item)
	local tw
	local fr
	local count
	if not itemResultWindow.toonWindow[toon] then
		itemResultWindow.toonWindow[toon] = UI.CreateFrame("Frame", "ToonInfo", itemResultWindow.scrollView)
		if not itemResultWindow.bottomToonWindow then
			itemResultWindow.toonWindow[toon]:SetPoint("TOPLEFT", itemResultWindow.scrollView, "TOPLEFT", 0, 0)
		else
			itemResultWindow.toonWindow[toon]:SetPoint("TOPLEFT", itemResultWindow.bottomToonWindow, "BOTTOMLEFT", 0, 0)
		end
		tw=itemResultWindow.toonWindow[toon]
		tw:SetWidth(400);
		tw.name = UI.CreateFrame("Text", "text", itemResultWindow.toonWindow[toon])
		tw.name:SetText(toon)
		tw.name:SetPoint("TOPLEFT", tw, "TOPLEFT", 2, 2)
		tw.name:SetWidth(100);
		tw.name:SetFontSize(20)
		tw.childcount=0
		tw.children={}
	else
		tw=itemResultWindow.toonWindow[toon]
	end
	itemResultWindow.bottomToonWindow=tw
	count=tw.childcount
	if not tw.children[count+1] then
		fr=UI.CreateFrame("Frame", "ToonInfo", tw)
		fr:SetPoint("TOPLEFT", tw, "TOPLEFT", 100, count*32)
		fr:SetWidth(300)
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
		fr.label = UI.CreateFrame("Text", "text", fr)
		fr.label:SetWidth(160)
		fr.label:SetPoint("TOPLEFT", fr, "TOPLEFT", 80, 0)
		fr.count = UI.CreateFrame("Text", "text", fr)
		fr.icon:SetWidth(32)		
		fr.count:SetPoint("TOPLEFT", fr, "TOPLEFT", 240, 0)
--		fr.count:SetBackgroundColor(0, 0.5, 0.5, 0.5)
		fr.count:SetFontSize(20)
	else
		fr=tw.children[count+1]
	end
	str=item.name
	if item.flavor then str=str .. "\n" .. item.flavor end
	if item.description then str=str .. "\n" .. item.description end
	fr.label:SetText(str)
	fr.icon:SetTexture("Rift", item.icon)
	if (slot:sub(1,4) == "sibg") or (slot:sub(1,4) == "sbbg") then
		fr.bag:SetTexture("ToonInfo", "box.png")
	elseif (slot:sub(1,4) == "seqp") then
		fr.bag:SetTexture("ToonInfo", "user.png")	
	elseif slot:sub(1,2) == "sw" then 
		fr.bag:SetTexture("ToonInfo", "wardrobe.png")
	elseif slot:sub(1,2) == "si" then 
		fr.bag:SetTexture("ToonInfo", "backpack.png")
	elseif (slot:sub(1,2) == "sb") or (slot:sub(1,2) == "sg") then 
		fr.bag:SetTexture("ToonInfo", "chest.png")
	else
		fr.bag:SetTexture("ToonInfo", "qmark.png")
	end
	if item.stack then
		fr.count:SetText("" .. item.stack)
	else
		fr.count:SetText("")
	end
	fr:SetVisible(true)
	tw.childcount = count+1
	tw:SetHeight(tw.childcount*32)
	tw:SetVisible(true)
	itemResultWindow.neededHeight=itemResultWindow.neededHeight+32
end

local function showItemResultWindow()

	if (itemResultWindow.neededHeight <= itemResultWindow.scrollView:GetHeight()) then
		itemResultWindow.scrollbar:SetVisible(false)
	else
		itemResultWindow.scrollbar:SetVisible(true)
		itemResultWindow.scrollbar:SetRange(0, itemResultWindow.neededHeight - itemResultWindow.scrollView:GetHeight())
		itemResultWindow.scrollbar:SetPosition(0)
	end
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
	local l,r,t,b=miniWindow:GetBounds()
	return l
end

function ToonInfo.createUI()
	context=UI.CreateContext("ToonInfo")
	-- context:SetSecureMode("restricted")
	
	if (miniWindow == nil) then
		if not ToonInfoChar.xpos then ToonInfoChar.xpos=100 end
		if not ToonInfoChar.ypos then ToonInfoChar.ypos=100 end
		ToonInfo.BuildMiniWindow()
		ToonInfo.BuildTooltipExtension()
	end
end
