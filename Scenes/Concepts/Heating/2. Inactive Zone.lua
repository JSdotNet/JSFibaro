



--SWITCHING OFF HEATING IN UNOCCUPIED ZONES
--When you are in a room, you want it to be well lit and nicely warmed.  However many times, we leave a room – expecting to return in 5 minutes, only to be distracted for one reason or another and forget that we haven’t turned off the heating.
--Using a Fibaro Motion sensor and Lua on the Home Center 2, we can detect the absence of movement in a room for an extended period of time, the heating can be turned down.

-- TODO: Trigger this scene when you start using the room

--[[
%% properties
65 value
%% globals
--]]
-- TODO put values above for devices that should trigger this scene

local debug = true					-- Set to false onse the scene is working as expected
local motionID = 65					-- The ID of the motion sensor
local danfossIDs = {0,0}			-- Id's off danfoss radiator heads to adjust
local delay = 60 * 60				-- 1 uur
local interval = 600000				-- Check every 10 minutes
local inactiveTemp = 15				-- Temperature while zone is not active
 

-- Only allow one instance of the current scene to run at a time
if (fibaro:countScenes() > 1) then
  fibaro:abort()
end
 
if (debug) then fibaro:debug("Scene started: Inactive Zone (Heating)"); end 

-- function that performs the action
function action()
	for key, danfossID in pairs(danfossIDs) do 
			
			fibaro:call(danfossID, 'setValue', inactiveTemp) -- Set Danfoss Temperature
	  end
end


local motion, mTime = fibaro:get(motionID, 'value')
if (debug) then fibaro:debug("motion " .. motion); end 
if (debug) then fibaro:debug("mTime " .. mTime); end 
 
motion = tonumber(motion);
mTime = os.time() - mTime; -- convert this to number of seconds ago.
if (debug) then fibaro:debug("motion " .. motion); end 
if (debug) then fibaro:debug("mTime " .. mTime); end 

local completed = false;
while (not completed) do
	if (motion > 0) then
		-- there is motion - reset timer
		mTime = os.time() - mTime
		if (debug) then fibaro:debug("mTime " .. mTime); end 
	else
		-- there is no motion - check if there has been no motion for the required time
		if (mTime >= delay) then
      
		  action() -- Perform the required action
		  completed = true
		end
	end

	fibaro:sleep(interval) -- give the system some breathing space

	-- then check it all again...
    motion, mTime = fibaro:get(motionID, 'value')
	if (debug) then fibaro:debug("motion " .. motion); end 
	if (debug) then fibaro:debug("mTime " .. mTime); end 

    motion = tonumber(motion);
    mTime = os.time() - mTime; -- convert this to number of seconds ago.
	if (debug) then fibaro:debug("mTime " .. mTime); end 
end -- jump back to the top of the loop