--[[
%% properties
%% events
%% globals
Presence
Activity
Time_WakeUp_Hour
Time_WakeUp_Minute
--]]

----- Scene Configuration -----
local activity = "Awake";                           -- Name of the Activity this scene relates to
local scene = "Activity To '" .. activity .. "'";	-- Name of the scene

-- General:
local debug = true; 

----- Get Wakeup Time -----
local wakeUpTime_Hours = fibaro:getGlobal('Time_WakeUp_Hour');		-- Integer value representing the hours of the time
local wakeUpTime_Minutes = fibaro:getGlobal('Time_WakeUp_Minute');		-- Integer value representing the minutes of the time
        
local currentTime = os.date("*t");
local sceneTime = os.time{year=currentTime.year, month=currentTime.month, day=(currentTime.hour < 10 and currentTime.day or currentTime.day + 1), hour=tonumber(wakeUpTime_Hours) + 2, minutes=tonumber(wakeUpTime_Minutes)};


local startSource = fibaro:getSourceTrigger();
if ( ( --fibaro:getGlobalValue("Presence") == "Home"  and  TODO: FOR NOW CYCLE IS INDEPENDEND FROM PRESENSE, THIS SHOULD BE REVIEWED ...
       fibaro:getGlobalValue("Activity") ~= activity and
       (os.time() > sceneTime) ) 
    or startSource["type"] == "other")
then

    ----- Only allow one instance of the current scene to run at a time -----
    if (fibaro:countScenes() > 1) then
        if (debug) then fibaro:debug(scene .. " - Aborting (Already Running) " .. dimlevel); end 
        fibaro:abort();
    end
    
    if (debug) then fibaro:debug(scene .. " - Started"); end
    
    if (debug) then fibaro:debug(scene .. " - Set Activity from: '" .. fibaro:getGlobalValue("Activity") .. "' to '" .. activity  .. "'"); end 
	fibaro:setGlobal("Activity", activity);
    
    if (debug) then fibaro:debug(scene .. " - Ended"); end
end