
-- As part of Saving Power (by turning off devices) when Away or Sleeping. 
-- The devices should be reanabled when at Home of Awake.


-- TODO: Trigger this scene when Home or Awake variable is changed


--[[
%% properties

%% globals
--]]




local debug = true					-- Set to false onse the scene is working as expected


-- Only allow one instance of the current scene to run at a time
if (fibaro:countScenes() > 1) then
  fibaro:abort()
end


if (debug) then fibaro:debug("Scene started: Saving Power - Turn Back On."); end 

local deviceIDs = fibaro:getGlobal('DevicesToTurnBackOnWhenHomeAndAwake')

for key, deviceID in pairs(deviceIDs) do 
	
	if (debug) then fibaro:debug("Saving Power - Turning on: " + fibaro:getName(deviceID) + " (" + fibaro:getRoomName( fibaro:getRoomID(deviceID) + ")."); end 		
	fibaro:call(deviceID, 'turnON') -- turning on the device
end

if (debug) then fibaro:debug("Scene ended: Saving Power - Turn Back On."); end 