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
local checkInterval = 10;			                -- Interval time in minutes between checks if trigger conditions are met

if (debug) then fibaro:debug(scene .. " - Started"); end

----- Only allow one instance of the current scene to run at a time -----
if (fibaro:countScenes() > 1) then
    if (debug) then fibaro:debug(scene .. " - Aborting (Already Running) "); end 
    fibaro:abort();
end

local completed = false;
while not completed do	

    -- Check if activity isn't already set --
    if (fibaro:getGlobalValue("Activity") == activity) then
        if (debug) then fibaro:debug(scene .. " - Aborting (State already set) "); end 
        fibaro:abort();
    end

    -- Get Wakeup Time --
    local wakeUpTime_Hours = fibaro:getGlobal('Time_WakeUp_Hour');		-- Integer value representing the hours of the time
    local wakeUpTime_Minutes = fibaro:getGlobal('Time_WakeUp_Minute');		-- Integer value representing the minutes of the time
            
    local currentTime = os.date("*t");
    
    -- sceneTime = 2 hours after wakeup
    local scene_Hours = wakeUpTime_Hours + 2;
  	local scene_Minutes = wakeUpTime_Minutes;
  	
    if (debug) then 
        fibaro:debug(scene .. ": scene hours => " .. scene_Hours);
        fibaro:debug(scene .. ": scene minutes => " .. scene_Minutes);
        
        fibaro:debug(scene .. ": os hours => " .. os.date("%H"));
        fibaro:debug(scene .. ": os minutes => " .. os.date("%M"));
    end

    --local startSource = fibaro:getSourceTrigger();
    if ( 
        --fibaro:getGlobalValue("Presence") == "Home"  and  TODO: FOR NOW CYCLE IS INDEPENDEND FROM PRESENSE, THIS SHOULD BE REVIEWED ...         
        tonumber(os.date("%H")) >= tonumber(scene_Hours) and 
        tonumber(os.date("%M")) >= tonumber(scene_Minutes)
        --or startSource["type"] == "other"
       )
    then
    
        if (debug) then fibaro:debug(scene .. " - Set Activity from: '" .. fibaro:getGlobalValue("Activity") .. "' to '" .. activity  .. "'"); end 
        fibaro:setGlobal("Activity", activity);
        
        completed = true;	  
        if (debug) then fibaro:debug(scene .. " - Completed"); end
    end
    
    fibaro:sleep(checkInterval*60*1000); -- give the system some breathing space
end

-- Don't start again today, sleep till midnight
fibaro:sleep(24 - os.date("%H")*60*1000); 
if (debug) then fibaro:debug(scene .. " - Ended"); end