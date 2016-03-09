--[[
%% properties
98 value
417 value
%% globals
--]]
 
local windowIDs = {0,0}				-- change this at the top if you change it here
local sensorID = 0					-- the sensor used to detect the temperature drop
local tempDropalert = 1				-- Allow a temp drop of x degrees before temp alert is triggered
local checkInterval = 30000			-- Check every 30 seconds
local alertRepeatInterval = 600000  -- Repeat alert every 10 minutes
 
-- Only allow one instance of the current scene to run at a time
if (fibaro:countScenes() > 1) then
  fibaro:abort()
end
 
function applyAlert()
	-- TODO: Trigger Temp Alert
end

function doorOrWindowOpen()
  local res = false
  -- check all the windows - are any open?
  for key, windowID in pairs(windowIDs) do -- TODO: REVIEW use off pairs ????
    -- is this window open?
    res = (res or (fibaro:getValue(windowID, "value") == '1'))
  end
  return res
end
 
local initialTemp = 'unknown'
 
if (doorOrWindowOpen()) then
  initialTemp = fibaro:getValue(sensorID, "value")
  local currentTemp = initialTemp;

  while doorOrWindowOpen() do
	
	if (initialTemp - currentTemp) < tempDropalert) then

		applyAlert()
	
		fibaro:sleep(alertRepeatInterval)
	else
		fibaro:sleep(checkInterval)
		currentTemp = fibaro:getValue(sensorID, "value")
	end
  end

  fibaro:sleep(100) -- make sure the message has gone through
end