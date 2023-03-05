
local name, width, height, titleheight,scrollbarwidth = "|cffffffffProfiler|r", 300, 150, 18,13

local PaneBackdrop  = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	edgeSize = 3,
	insets = {left = 1, right = 1, top = 1, bottom = 1},
}
local ButtonBackdrop  = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	edgeSize = 3,
	insets = {left = 1, right = 1, top = 1, bottom = 1},
}

local function CloseFrame(frame)
	frame:Hide()
end

-- CREATE FRAME
local frame = CreateFrame("Frame", "LOP_FRAME", nil, "BackdropTemplate")
frame:SetPoint("CENTER", 120, 0)
frame:SetSize(width, height)
frame:SetBackdrop(PaneBackdrop)
frame:SetBackdropColor(0,0,0,0.6)
frame:SetBackdropBorderColor(0.3,0.3,0.3,1)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving) -- TODO: only allow draggin for frame.top ?
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

frame.closebutton = CreateFrame("Button", nil, frame, "BackdropTemplate")
frame.closebutton:SetScript("OnClick", function(frameholder) CloseFrame(frame) end)
frame.closebutton:SetPoint("TOPRIGHT", -3, -3)
frame.closebutton:SetHeight(12)
frame.closebutton:SetWidth(12)
frame.closebutton:SetBackdrop(ButtonBackdrop)
frame.closebutton:SetBackdropColor(0.2,0.2,0.2, 0.5)
frame.closebutton:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
frame.closebutton:SetScript("OnEnter",function()
	frame.closebutton:SetBackdropColor(0.6,0.2,0.2, 0.5)
end)
frame.closebutton:SetScript("OnLeave",function()
	frame.closebutton:SetBackdropColor(0.2,0.2,0.2, 0.5)
end)
frame.closebutton.text = frame.closebutton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
frame.closebutton.text:SetPoint("CENTER")
frame.closebutton.text:SetJustifyH("CENTER")
frame.closebutton.text:SetFont("Fonts\\FRIZQT__.ttf", 7)
frame.closebutton.text:SetText("|cffff0000X")

-- title bar-ish
frame.top = CreateFrame("Frame", "LOP_TITLE", frame,"BackdropTemplate")
frame.top:SetSize(width, titleheight)
frame.top:SetPoint("TOP", 0, 0)
frame.top:SetBackdrop(PaneBackdrop)
frame.top:SetBackdropColor(0.3,0.3,0.3,0.6)
frame.top:SetBackdropBorderColor(0.3,0.3,0.3,0.6)


frame.title = frame.top:CreateFontString("LOP_TEXT", "ARTWORK", "GameFontNormal")
frame.title:SetFont("GameFontNormalSmall", 14)
frame.title:SetPoint("TOPLEFT",  4, -3)
frame.title:SetText(name)

local frameHolder = frame;
 
-- create the frame that will hold all other frames/objects:
local frameholder = frameHolder or CreateFrame("Frame", nil, UIParent); -- re-size this to whatever size you wish your ScrollFrame to be, at this point
 
frameholder.scrollframe = frameholder.scrollframe or CreateFrame("ScrollFrame", "ANewScrollFrame", frame, "UIPanelScrollFrameTemplate");
frameholder.scrollframe:SetPoint("TOPLEFT",0,-titleheight)
frameholder.scrollframe:SetPoint("BOTTOMRIGHT",-10,0)

frameholder.editbox = frameholder.editbox or CreateFrame("EditBox", name, frame, "BackdropTemplate")
frameholder.editbox:SetMultiLine(true)
frameholder.editbox:SetSize(width-scrollbarwidth,900)
frameholder.editbox:SetPoint("TOPLEFT", frameholder.scrollframe)
frameholder.editbox:SetPoint("BOTTOMRIGHT", frameholder.scrollframe)
frameholder.editbox:SetFontObject(ChatFontNormal)
frameholder.editbox:SetMaxLetters(999999)
frameholder.editbox:SetAutoFocus(false)
frameholder.editbox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end) 

frameholder.editbox:SetTextInsets(3,0,0,0)

frameholder.editbox:SetBackdrop(PaneBackdrop)
frameholder.editbox:SetBackdropColor(0.3, 0.3, 0.3, 0.2)
frameholder.editbox:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

frameholder.scrollframe:SetScrollChild(frameholder.editbox)

-- define the scrollframe's objects/elements:
local scrollbarName = frameholder.scrollframe:GetName()
frameholder.scrollbar = _G[scrollbarName.."ScrollBar"];
frameholder.scrollupbutton = _G[scrollbarName.."ScrollBarScrollUpButton"];
frameholder.scrolldownbutton = _G[scrollbarName.."ScrollBarScrollDownButton"];
frameholder.scrollslider = _G[scrollbarName.."ScrollBarThumbTexture"]
 
-- all of these objects will need to be re-anchored (if not, they appear outside the frame and about 30 pixels too high)
frameholder.scrollupbutton:ClearAllPoints();
frameholder.scrollupbutton:SetPoint("TOPRIGHT", frameholder.scrollframe, "TOPRIGHT", 9, -2);
frameholder.scrollupbutton:SetWidth(12)
frameholder.scrollupbutton:SetHeight(12)
 
frameholder.scrolldownbutton:ClearAllPoints();
frameholder.scrolldownbutton:SetPoint("BOTTOMRIGHT", frameholder.scrollframe, "BOTTOMRIGHT", 9, 2);
frameholder.scrolldownbutton:SetWidth(12)
frameholder.scrolldownbutton:SetHeight(12)
 
frameholder.scrollbar:ClearAllPoints();
frameholder.scrollbar:SetPoint("TOP", frameholder.scrollupbutton, "BOTTOM", 0, -2);
frameholder.scrollbar:SetPoint("BOTTOM", frameholder.scrolldownbutton, "TOP", 0, 2);
frameholder.scrollbar:SetWidth(11)

frameholder.scrollslider:SetWidth(11)
frameholder.scrollslider:SetHeight(18)

frameholder.editbox:SetText("Profiler data will be shown here!")

-- you should now need to scroll down to see the text "This is a test."

ProfilerData = {}

local function tickProfiler()
    -- PoC, move to onUpdate/Event?
    if (_G.LUA_OBFUSCATOR_Profiler ~= nil) then
        local data = "";
		--local funcTimes = {};
		local inFuncs = {};

        -- empty _G.LUA_OBFUSCATOR_Profiler
		for k, v in pairs(_G.LUA_OBFUSCATOR_Profiler) do
			if (type(v) == "table") then
				local fname = k;
				if (ProfilerData[fname] == nil) then
					ProfilerData[fname] = { }
                    ProfilerData[fname].name = fname
                    ProfilerData[fname].totalTime = 0
                    ProfilerData[fname].count = 0
				end
				for kk, vv in pairs(v) do
					local infoTick = tostring(vv);
					local type = "out";
					if (string.sub(infoTick, 1, 3) == " > ") then
						type = "in";
					end
					local ticktime = string.sub(infoTick, 3, #infoTick - 3);
					
                    -- can this even work in all conditions?
                    if (type == "in") then
						inFuncs[fname] = ticktime;
					elseif ((type == "out") and (inFuncs[fname] ~= nil)) then
						ProfilerData[fname].totalTime = ProfilerData[fname].totalTime + (ticktime - inFuncs[fname]);
						inFuncs[fname] = nil;
					end
				end
                ProfilerData[fname].count = ProfilerData[fname].count + #LUA_OBFUSCATOR_Profiler[fname]
                LUA_OBFUSCATOR_Profiler[fname] = nil -- empty results
			end
		end

        -- TODO: print this in GUI
		local data = {}
		for name, vv in pairs(ProfilerData) do
            if type(vv) == "table" then
                table.insert(data, name)
				table.insert(data, ": ")
				table.insert(data, tonumber(string.format("%.6f", vv.totalTime)))
				table.insert(data, "s (count: ")
				table.insert(data, vv.count)
				table.insert(data, ")\n")
            end
		end
		frameholder.editbox:SetText(table.concat(data))
    end
    C_Timer.After(10, tickProfiler)
end
tickProfiler();
