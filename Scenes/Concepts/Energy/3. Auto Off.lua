
-- Scene to turn off devices when they have been on for a certain amount of time
-- This scene is intended for when there is no motion sensor to check for activity, the scene is triggered when any of the devices is turned on
-- While any of the devices is still on it periodicaly checks if the amount of time for that device (variable: times) has passed
-- if so, it wil turn of that device, when all devices are off the scene will end
 

-- TODO: Maybe use global variable for times devices?
-- TODO: Possible issue when one of the devices is turned on while scene already running (maybe use sourcetrigger to compensate?)


--[[
%% properties
56 value
78 value
29 value
40 value
%% globals
--]]

local debug = true					-- Set to false onse the scene is working as expected
local deviceIDs = {56, 78, 29, 40}	-- The devices that should turn off automatically (should be the same list as above)
local times   = {60, 30, 900, 600}	-- each time (in seconds) here relates to each device above.
local interval = 600000				-- Check every 10 minutes
 
-- Only allow one instance of the current scene to run at a time
if (fibaro:countScenes() > 1) then	
  fibaro:abort()
end
 
if (debug) then fibaro:debug("Scene started: Auto Off"); end 

-- return true if all devices in the list are off
function allAreOff(deviceList)
  local res = true
  for key, deviceID in pairs(deviceList) do
    local val = fibaro:getValue(deviceID, 'value')
    res = res and (val == '0') -- true if this and all previous devices are off
  end
  return res
end
 
while (not allAreOff(deviceIDs)) do
  -- check each device to see if it needs to be turned off.
  for key, deviceID in pairs(deviceIDs) do
    local val, timesince = fibaro:get(deviceID, 'value')
    val = tonumber(val)
    timesince = os.time() - timesince
    if ((val > 0) and (timesince > times[key])) then -- it's on and it has been on for too long
	 
	  if (debug) then fibaro:debug("Auto Off - " + timesince + " elapsed for: " + fibaro:getName(deviceID) + " (" + fibaro:getRoomName(fibaro:getRoomID(deviceID) + ")."); end 
	  if (debug) then fibaro:debug("Auto Off - Turning off: " + fibaro:getName(deviceID) + " (" + fibaro:getRoomName(fibaro:getRoomID(deviceID) + ")."); end 

      fibaro:call(deviceID, 'turnOff') -- turn it off

    end
  end
  fibaro:sleep(interval) -- 1 second of peace
end

if (debug) then fibaro:debug("Scene ended: Auto Off"); end 