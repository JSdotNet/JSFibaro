--[[
%% properties
%% events
%% globals
Presence
Activity
Time_Sleep_Hour
Time_Sleep_Minute
--]]

----- Scene Configuration -----
local activity = "Going to Sleep";                  -- Name of the Activity this scene relates to
local scene = "Activity To '" .. activity .. "'";	-- Name of the scene

-- General:
local debug = true; 
local checkInterval = 10;			                -- Interval time in minutes between checks if trigger conditions are met

if (debug) then fibaro:debug(scene .. " - Started"); end

----- Only allow one instance of the current scene to run at a time -----
if (fibaro:countScenes() > 1) then
    if (debug) then fibaro:debug(scene .. " - Aborting (Already Running)"); end 
    fibaro:abort();
end

local completed = false;
while not completed do	

    -- Check if activity isn't already set --
    if (fibaro:getGlobalValue("Activity") ~= activity) then
        if (debug) then fibaro:debug(scene .. " - Aborting (State already set)"); end 
        fibaro:abort();
    end

    ----- Get Wakeup Time -----
    local sleepTime_Hours = fibaro:getGlobal('Time_Sleep_Hour');		-- Integer value representing the hours of the time
    local sleepTime_Minutes = fibaro:getGlobal('Time_Sleep_Minute');		-- Integer value representing the minutes of the time
            
    local currentTime = os.date("*t");
    
    -- sceneTime = 2 hours before sleep time
    local sceneTime = os.time{year=currentTime.year, month=currentTime.month, day=(currentTime.hour < 10 and currentTime.day or currentTime.day + 1), hour=tonumber(sleepTime_Hours) - 2, minutes=tonumber(sleepTime_Minutes)};


    --local startSource = fibaro:getSourceTrigger();
    if ( 
        --fibaro:getGlobalValue("Presence") == "Home"  and  TODO: FOR NOW CYCLE IS INDEPENDEND FROM PRESENSE, THIS SHOULD BE REVIEWED ...
        os.time() > sceneTime 
        --or startSource["type"] == "other"
       )
    then
        if (debug) then fibaro:debug(scene .. " - Set Activity from: '" .. fibaro:getGlobalValue("Activity") .. "' to '" .. activity  .. "'"); end  
        fibaro:setGlobal("Activity", activity);
        
        if (debug) then fibaro:debug(scene .. " - Ended"); end
    end
    
    fibaro:sleep(checkInterval*60*1000); -- give the system some breathing space
end