-- slash commands:
-- /nped text: toggles using a nameplate '+' symbol for elite mobs (default: off)
-- /nped icon: toggles using a nameplate dragon icon for elite mobs (default: on)

local usage_message = 'Nameplate EliteDragon: Usage:\n/nped icon: toggles showing a dragon icon on the nameplate of elite mobs (default: on)\n/nped text: toggles showing a (+) marker on the nameplate of elite mobs (default: off)'
local useTextDefault = false;
local useTextureDefault = true;

local NamePlateEliteMarkerText = {};
local NamePlateEliteMarkerTexture = {};
local NamePlateRareEliteMarkerTexture = {};

local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("NAME_PLATE_CREATED")
EventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
EventFrame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded


EventFrame:SetScript("OnEvent", function(self,event,...) 
	
	if event == "ADDON_LOADED" and ... == "NamePlateEliteDragon" then
		if NamePlateEliteDragonUseText == nil or NamePlateEliteDragonUseTexture == nil then
			NamePlateEliteDragonUseText = useTextDefault;
			NamePlateEliteDragonUseTexture = useTextureDefault;
			print(usage_message)
			print('(This message is only shown on the first load)')
		end
	end
	
	-- nameplate creation (fired seldomly because nameplates are reused)
	if event == 'NAME_PLATE_CREATED' then
		local base = ...
		local unitframe = base.UnitFrame;
		
		-- create '+' text and hide
		local text = unitframe.healthBar:CreateFontString(nil, "OVERLAY")
		text:SetFont("Fonts\\ArialN.ttf", 10, "THICKOUTLINE")
		text:SetPoint("LEFT", 1, -0.5)
		text:SetTextColor(0, 1, 0)
		text:SetText('+')
		text:SetShown(false)
		NamePlateEliteMarkerText[unitframe] = text
		
		-- create dragon icon and hide
		local texture = unitframe.LevelFrame:CreateTexture(nil, "OVERLAY", nil, 7)
		texture:SetTexture('Interface\\AddOns\\NamePlateEliteDragon\\EliteNameplateIcon.tga')
		texture:SetSize(56, 28)
		texture:SetPoint("RIGHT", 35, -3.4)
		texture:SetShown(false)
		NamePlateEliteMarkerTexture[unitframe] = texture;
		
		-- create rare dragon icon and hide
		local raretexture = unitframe.LevelFrame:CreateTexture(nil, "OVERLAY", nil, 7)
		raretexture:SetTexture('Interface\\AddOns\\NamePlateEliteDragon\\RareEliteNameplateIcon.tga')
		raretexture:SetSize(56, 28)
		raretexture:SetPoint("RIGHT", 35, -3.4)
		raretexture:SetShown(false)
		NamePlateRareEliteMarkerTexture[unitframe] = raretexture;
	end
	
	-- namplate is being shown with a new unit
	if event == 'NAME_PLATE_UNIT_ADDED' then
		local unitToken = ...
		local classification = UnitClassification(unitToken)
		local nameplate = C_NamePlate.GetNamePlateForUnit(unitToken).UnitFrame
		-- print('unitname: ' .. UnitName(unitToken))
		
		if classification == "elite" or classification == "worldboss" then
			-- print('Adding elite on' .. unitToken)
			if NamePlateEliteDragonUseText then NamePlateEliteMarkerText[nameplate]:SetShown(true) end
			if NamePlateEliteDragonUseTexture then 
				NamePlateEliteMarkerTexture[nameplate]:SetShown(true) 
				NamePlateRareEliteMarkerTexture[nameplate]:SetShown(false)
			end
		elseif classification == "rareelite" or classification == "rare" then
			-- print('Adding rare elite on' .. unitToken)
			if NamePlateEliteDragonUseText then NamePlateEliteMarkerText[nameplate]:SetShown(true) end
			if NamePlateEliteDragonUseTexture then 
				NamePlateEliteMarkerTexture[nameplate]:SetShown(false) 
				NamePlateRareEliteMarkerTexture[nameplate]:SetShown(true)
			end
		else 
			-- print('Removing elite on' .. unitToken)
			if NamePlateEliteDragonUseText then NamePlateEliteMarkerText[nameplate]:SetShown(false) end
			if NamePlateEliteDragonUseTexture then 
				NamePlateEliteMarkerTexture[nameplate]:SetShown(false) 
				NamePlateRareEliteMarkerTexture[nameplate]:SetShown(false)
			end
		end
	
	end
end)

-- slash commands
local function NamePlateEliteDragonCommands(msg, editbox)
	if msg == 'text' then
		if (NamePlateEliteDragonUseText) then
			NamePlateEliteDragonUseText = false
		else
			NamePlateEliteDragonUseText = true
		end
		print('Nameplate EliteDragon: Showing the Elite Text is now: ' .. (NamePlateEliteDragonUseText and 'on' or 'off') .. ' (Nameplates must be off-screen to refresh)')
	elseif msg == 'icon' or msg == 'texture' then
		if (NamePlateEliteDragonUseTexture) then
			NamePlateEliteDragonUseTexture = false
		else
			NamePlateEliteDragonUseTexture = true
		end
		print('Nameplate EliteDragon: Showing the Elite Icon is now: ' .. (NamePlateEliteDragonUseTexture and 'on' or 'off') .. ' (Nameplates must be off-screen to refresh)')
	else
		print(usage_message)
	end
end

SLASH_NAMEPLATEELITEDRAGON1, SLASH_NAMEPLATEELITEDRAGON2 = '/nped', '/nameplateelitedragon'
SlashCmdList["NAMEPLATEELITEDRAGON"] = NamePlateEliteDragonCommands
