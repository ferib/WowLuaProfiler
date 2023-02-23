
local name, width, height = "Profiler", 300, 150 

-- CREATE FRAME
frame = CreateFrame("Frame", "LOP_FRAME", nil)
frame:SetPoint("CENTER", 120, 0)
frame:SetSize(width, height)
frame.bck = frame:CreateTexture("ARTWORK")
frame.bck:SetAllPoints()
frame.bck:SetColorTexture(0.23, 0.23, 0.23, 0.5)

-- title bar-ish
frame.top = CreateFrame("Frame", "LOP_TITLE", frame)
frame.top:SetSize(width-4, 16)
frame.top:SetPoint("TOP", 0, -2)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving) -- TODO: only allow draggin for frame.top ?
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame.top.bck = frame.top:CreateTexture("ARTWORK")
frame.top.bck:SetAllPoints()
frame.top.bck:SetColorTexture(0.23, 0.23, 0.23, 0.5)
frame.title = frame:CreateFontString("LOP_TEXT", "ARTWORK", "GameFontNormal")
frame.title:SetFont("GameFontNormal", 14)
frame.title:SetPoint("TOPLEFT",  4, -4)
frame.title:SetText("" .. name)

local frameHolder = frame;
 
-- create the frame that will hold all other frames/objects:
local self = frameHolder or CreateFrame("Frame", nil, UIParent); -- re-size this to whatever size you wish your ScrollFrame to be, at this point
 
-- now create the template Scroll Frame (this frame must be given a name so that it can be looked up via the _G function (you'll see why later on in the code)
self.scrollframe = self.scrollframe or CreateFrame("ScrollFrame", "ANewScrollFrame", self, "UIPanelScrollFrameTemplate");
 
-- create the standard frame which will eventually become the Scroll Frame's scrollchild
-- importantly, each Scroll Frame can have only ONE scrollchild
self.scrollchild = self.scrollchild or CreateFrame("Frame"); -- not sure what happens if you do, but to be safe, don't parent this yet (or do anything with it)
 
-- define the scrollframe's objects/elements:
local scrollbarName = self.scrollframe:GetName()
self.scrollbar = _G[scrollbarName.."ScrollBar"];
self.scrollupbutton = _G[scrollbarName.."ScrollBarScrollUpButton"];
self.scrolldownbutton = _G[scrollbarName.."ScrollBarScrollDownButton"];
 
-- all of these objects will need to be re-anchored (if not, they appear outside the frame and about 30 pixels too high)
self.scrollupbutton:ClearAllPoints();
self.scrollupbutton:SetPoint("TOPRIGHT", self.scrollframe, "TOPRIGHT", -2, -2);
 
self.scrolldownbutton:ClearAllPoints();
self.scrolldownbutton:SetPoint("BOTTOMRIGHT", self.scrollframe, "BOTTOMRIGHT", -2, 2);
 
self.scrollbar:ClearAllPoints();
self.scrollbar:SetPoint("TOP", self.scrollupbutton, "BOTTOM", 0, -2);
self.scrollbar:SetPoint("BOTTOM", self.scrolldownbutton, "TOP", 0, 2);
 
-- now officially set the scrollchild as your Scroll Frame's scrollchild (this also parents self.scrollchild to self.scrollframe)
-- IT IS IMPORTANT TO ENSURE THAT YOU SET THE SCROLLCHILD'S SIZE AFTER REGISTERING IT AS A SCROLLCHILD:
self.scrollframe:SetScrollChild(self.scrollchild);
 
-- set self.scrollframe points to the first frame that you created (in this case, self)
self.scrollframe:SetAllPoints(self);
 
-- now that SetScrollChild has been defined, you are safe to define your scrollchild's size. Would make sense to make it's height > scrollframe's height,
-- otherwise there's no point having a scrollframe!
-- note: you may need to define your scrollchild's height later on by calculating the combined height of the content that the scrollchild's child holds.
-- (see the bit below about showing content).

-- TODO: dynamic sizing?
--local size = #items * lineHeight
self.scrollchild:SetSize(self.scrollframe:GetWidth(), ( self.scrollframe:GetHeight() * 2 ));
 
 
-- THE SCROLLFRAME IS COMPLETE AT THIS POINT.  THE CODE BELOW DEMONSTRATES HOW TO SHOW DATA ON IT.
 
 
-- you need yet another frame which will be used to parent your widgets etc to.  This is the frame which will actually be seen within the Scroll Frame
-- It is parented to the scrollchild.  I like to think of scrollchild as a sort of 'pin-board' that you can 'pin' a piece of paper to (or take it back off)
self.moduleoptions = self.moduleoptions or CreateFrame("Frame", nil, self.scrollchild);
self.moduleoptions:SetAllPoints(self.scrollchild);
 
-- a good way to immediately demonstrate the new scrollframe in action is to do the following...
 
-- create a fontstring or a texture or something like that, then place it at the bottom of the frame that holds your info (in this case self.moduleoptions)
self.moduleoptions.fontstring = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
self.moduleoptions.fontstring:SetText("FunctionTest1");
self.moduleoptions.fontstring:SetPoint("BOTTOMLEFT", self.moduleoptions, "BOTTOMLEFT", 20, 60);
 
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
		for name, vv in pairs(ProfilerData) do
            if type(vv) == "table" then
                print(name .. ": " .. (tonumber(string.format("%.6f", vv.totalTime))) .. "s (count: " .. vv.count .. ")");
            end
		end
    end
    C_Timer.After(5, tickProfiler)
end
tickProfiler();
