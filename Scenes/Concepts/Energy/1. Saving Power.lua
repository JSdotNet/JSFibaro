
-- Scene to Save Power (by turning off devices)


-- TODO: Trigger this scene when Away or Sleeping variable is changed


--[[
%% properties

%% globals
--]]



local debug = true	-- Set to false onse the scene is working as expected


-- Only allow one instance of the current scene to run at a time
if (fibaro:countScenes() > 1) then
  fibaro:abort()
end

if (debug) then fibaro:debug("Scene started: Saving Power."); end 

local deviceIDs = fibaro:getGlobal('DevicesToTurnOffWhenAwayOrSleeping')

for key, deviceID in pairs(deviceIDs) do 
	
	if (debug) then fibaro:debug("Saving Power - Turning off: " + fibaro:getName(deviceID) + " (" + fibaro:getRoomName( fibaro:getRoomID(deviceID) + ")."); end 		
	fibaro:call(deviceID, 'turnOff') -- turning off the device
end

if (debug) then fibaro:debug("Scene ended: Saving Power."); end 


-- LATER:
-- TODO: Maybe extend this to include devices that can be turned of when they are done, like washer.
