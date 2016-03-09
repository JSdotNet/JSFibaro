--[[
%% properties
98 value
417 value
%% globals
--]]
 
local windowIDs = {0,0} -- change this at the top if you change it here
local thermostatID = 0
local targetTempDrop = 5 -- Don't let the temperature get to low, since that would drive the cost of reheating the room
local checkInterval = 30000 -- Check every 30 seconds

-- Only allow one instance of the current scene to run at a time
if (fibaro:countScenes() > 1) then
  fibaro:abort()
end
 
function windowOpen()
  local res = false
  -- check all the windows - are any open?
  for key, windowID in pairs(windowIDs) do -- TODO: REVIEW use off pairs ????
    -- is this window open?
    res = (res or (fibaro:getValue(windowID, "value") == '1'))
  end
  return res
end
 
local oldSetPoint = 'unknown'
 
if (windowOpen()) then
  oldSetPoint = fibaro:getValue(thermostatID, "value")
  newSetPoint = oldSetPoint - targetTempDrop;
  if (newSetPoint < 0) -- Prefent temp below 0
	newSetPoint = 0;

  fibaro:call(thermostatID, "setTargetLevel", "5")
  while windowOpen() do
    fibaro:sleep(checkInterval)
  end
  fibaro:call(thermostatID, "setTargetLevel", oldSetPoint)
  fibaro:sleep(100) -- make sure the message has gone through
end