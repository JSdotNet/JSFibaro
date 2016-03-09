
-- Scene to switch of light when an area is not in use
-- The scene should activate any of the devices (variable: deviceIDs) in the room is turned On, it then used a motion sensor (variable: motionID) to monitor activity and
-- when no activity is detected for a while (variable: delay) it turns the devices off


-- TODO: Trigger this scene when any of the devices in the room is turned On (variable: deviceIDs)


--[[
%% properties
0 value
0 value
%% globals
--]]

local debug = true					-- Set to false onse the scene is working as expected
local motionID = 65					-- The ID of the motion sensor
local deviceIDs = {0,0}				-- Id's off lights to turn off (should be the same list as above)
local delay = 10 * 60				-- 10 minutes
local interval = 60000				-- Check every 10 minutes
 
-- Only allow one instance of the current scene to run at a time
if (fibaro:countScenes() > 1) then
  fibaro:abort()
end
 
if (debug) then fibaro:debug("Scene started: Detect Zone Inactive"); end 

-- function that performs the action
function action()	
	for key, deviceID in pairs(deviceIDs) do 
		if (debug) then fibaro:debug("Detect Zone Inactive - Turning off: " + fibaro:getName(deviceID) + " (" + fibaro:getRoomName( fibaro:getRoomID(deviceID) + ")."); end 
		fibaro:call(deviceID, 'turnOff') -- light off
	end
end


local motion, mTime = fibaro:get(motionID, 'value')
if (debug) then fibaro:debug("DEBUG PARAMETER (motion): " .. motion); end 
if (debug) then fibaro:debug("DEBUG PARAMETER (mTime): " .. mTime); end 
 
motion = tonumber(motion)
mTime = os.time() - mTime -- convert this to number of seconds ago.
if (debug) then fibaro:debug("DEBUG PARAMETER (motion): " .. motion); end 
if (debug) then fibaro:debug("DEBUG PARAMETER (mTime): " .. mTime); end 

local completed = false;
while (not completed) do
	
	if (motion > 0) then
		-- there is motion - reset timer
		mTime = os.time() - mTime
		if (debug) then fibaro:debug("DEBUG PARAMETER (mTime): " .. mTime); end 
	else
		-- there is no motion - check if there has been no motion for the required time
		if (mTime >= delay) then
		  if (debug) then fibaro:debug("Detect Zone Inactive: No motion detected for " + delay / 60 + " minutes."); end 

		  action() -- Perform the required action
		  completed = true
		end
	end

	fibaro:sleep(interval) -- give the system some breathing space

	-- then check it all again...
    motion, mTime = fibaro:get(motionID, 'value')
	if (debug) then fibaro:debug("DEBUG PARAMETER (motion): " .. motion); end 
	if (debug) then fibaro:debug("DEBUG PARAMETER (mTime): " .. mTime); end 

    motion = tonumber(motion)
    mTime = os.time() - mTime -- convert this to number of seconds ago.
	if (debug) then fibaro:debug("DEBUG PARAMETER (mTime): " .. mTime); end 
end -- jump back to the top of the loop
