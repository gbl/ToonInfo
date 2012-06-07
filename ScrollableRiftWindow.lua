
function ToonInfo.CreateScrollableRiftWindow(name, title, context)
	local newWindow

	newWindow=UI.CreateFrame("RiftWindow", name, context)
	newWindow:SetPoint("CENTER", UIParent, "CENTER", 0,0)
	newWindow:SetController("content")
	newWindow:SetWidth(440)
	newWindow:SetTitle(title)
	newWindow:SetBackgroundColor(0, 0, 0, 1)

	local closeButton = UI.CreateFrame("RiftButton", name.."CloseButton", newWindow)
	closeButton:SetSkin("close")
	closeButton:SetPoint("TOPRIGHT", newWindow, "TOPRIGHT", 0, -40)
	function closeButton.Event:LeftPress()
		newWindow:SetVisible(false)
	end

	local mask=UI.CreateFrame("Mask", name.."Mask", newWindow)
	mask:SetPoint("TOPLEFT", newWindow, "TOPLEFT", 0, 0)
	mask:SetPoint("BOTTOMRIGHT", newWindow, "BOTTOMRIGHT", -15, 0)
	
	local content=UI.CreateFrame("Frame", name.."Content", mask)
	content:SetAllPoints()

	local scrollbar = UI.CreateFrame("RiftScrollbar", name.."Scrollbar", newWindow)
	scrollbar:SetOrientation("vertical")
	scrollbar:SetLayer(10)

	scrollbar:SetPoint("TOPRIGHT", newWindow, "TOPRIGHT", 0, 0)
	scrollbar:SetPoint("BOTTOMRIGHT", newWindow, "BOTTOMRIGHT", 0, 0)
	scrollbar:SetWidth(15)

	scrollbar.Event.ScrollbarChange = function()
		local pos=scrollbar:GetPosition()
		-- print("positioning to "..pos)
		content:SetPoint("TOPLEFT", newWindow, "TOPLEFT", 0, -pos)
	end

	local border = newWindow:GetBorder()
	function border.Event:LeftDown()
		self.leftDown = true
		local mouse = Inspect.Mouse()
		self.originalXDiff = mouse.x - self:GetLeft() - 18
		self.originalYDiff = mouse.y - self:GetTop() - 60
		local left, top, right, bottom = newWindow:GetBounds()
		newWindow:ClearAll()
		newWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", left, top)
		newWindow:SetWidth(right-left)
		newWindow:SetHeight(bottom-top)		
	end
	function border.Event:LeftUp()
		self.leftDown = false
	end
	function border.Event:LeftUpoutside()
		self.leftDown = false
	end
	function border.Event:MouseMove(x, y)
		if not self.leftDown then
			return
		end
		newWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x - self.originalXDiff, y - self.originalYDiff)
	end	
	
	function content:SetVisible(flag)
		newWindow:SetVisible(flag)
	end
	
	function content:GetVisible()
		return newWindow:GetVisible()
	end
	
	function content:SetWidth(x)
		newWindow:SetWidth(x+15)
	end
	
	function content:SetHeight(x)
		local frameHeight=newWindow:GetHeight()
		if (x <= frameHeight) then
			scrollbar:SetVisible(false)
		else
			-- print("need height ".. x .. " frame has " .. frameHeight .. ": set scrollbar to " .. (x-frameHeight))
			scrollbar:SetRange(0, x-frameHeight)
			scrollbar:SetVisible(true)
		end
	end

	return content
end
