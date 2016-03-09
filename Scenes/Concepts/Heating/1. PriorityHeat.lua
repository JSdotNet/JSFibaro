
-- Close all radiator so that remaining radiators get priority

--[[
%% properties
65 value
%% globals
--]]

local danfossIDs = {0,0}			-- change this at the top if you change it here
local tempSensorId = 0				-- sensor that detects the target temperature
local targetTemp = 20				-- target temperature
local checkInterval = 600000		-- Check every 10 minutes

-- Only allow one instance of the current scene to run at a time
if (fibaro:countScenes() > 1) then
  fibaro:abort()
end
 
local currentTemp = fibaro:getValue(sensorID, "value")
local setpoints = {}

if (currentTemp < targetTemp) then
	 for key, danfossID in pairs(danfossIDs) do
			setpoints[key] = fibaro:get(danfossID, 'value')
			fibaro:call(danfossID, 'setValue', 0)
	  end

	  -- TODO: Make sure heating is on
end


while (currentTemp < targetTemp) do
	fibaro:sleep(checkInterval) -- give the system some breathing space
end

-- return values to old setpoint
for key, danfossID in pairs(danfossIDs) do

	fibaro:call(danfossID, 'setValue', setpoints[key])
end
