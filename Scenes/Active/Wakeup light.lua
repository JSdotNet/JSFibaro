--[[
%% properties
%% events
%% globals
Presence
Activity
--]]

-- Description
-- Wakeup light is trigger x minutes before (depending on configuration) the configured wakeup time.
-- It slowly lights up to max light level and then (optionaly) handsover the task to other lights.   


----- Scene Configuration -----
local scene = "Wake up light";	-- Name of the scene

-- General:
local debug = true; 
local checkInterval = 10;			-- Interval time in minutes between checks if trigger conditions are met

-- Devices:
local wakeUpLight = 132;			-- dimable light to control 
local handOverlights = { 67, 69 };	-- If specified the scene will turn on normal light when full level is reached (nil turns this option off)

-- Dimmer configuration:
local startlevel = 0;				-- start dim level 
local maxlevel = 100;				-- max dim level 
local diminterval = 1;				-- interval time in minutes to wait to next dimlevel 
local levelsteps = 20;				-- Number of steps to increase to target level
-- This configuration increses the light level in 20 minutes (20 steps with 1 minute interval)

-- Scenae Trigger
local startSource = fibaro:getSourceTrigger(); -- Start when at Home and Sleeping
if ( ( fibaro:getGlobalValue("Presence") == "Home"  and  
       fibaro:getGlobalValue("Activity") == "Sleeping" )
    or startSource["type"] == "other") -- Support manual start
then
	
    ----- Only allow one instance of the current scene to run at a time -----
    if (fibaro:countScenes() > 1) then
        if (debug) then fibaro:debug(scene .. " - Aborting (Already Running) " .. dimlevel); end 
        fibaro:abort();
    end


    ----- Implementation (Supporting Functions) -----
    function increaseLight(deviceId)
        local dimlevel; 

        if (maxlevel > 100) then maxlevel = 100; end 
        if (startlevel > maxlevel) then startlevel = maxlevel; end 

        local increasePerStep = math.ceil((targetlevel - startlevel) / levelsteps);

        if (debug) then fibaro:debug(scene .. " - Increase Started" ); end
        for level = startlevel, maxlevel, increasePerStep do 
            
            dimlevel = level; 
            
            if (dimlevel > 100) then  -- Prevent Level above 100%
                dimlevel = 100; 
            end 
            
            fibaro:call(deviceId, "setValue", dimlevel); 
            if (debug) then fibaro:debug(scene .. " - Set dim level at: " .. dimlevel); end 
            
            fibaro:sleep(diminterval*60*1000);
        end 
    end


    function handOver()
        
        if (handOverlights ~= nil)
        then
            if (debug) then fibaro:debug(scene .. " - Hand over to 'main lights'"); end 
            for key, deviceID in pairs(handOverlights) do
                if (debug) then fibaro:debug(scene .. " - Turn On: " .. fibaro:getName(deviceID)); end 
                fibaro:call(deviceID, 'turnOn') -- turning on the device			
            end

            if (debug) then fibaro:debug(scene .. " - Turn Off: " .. fibaro:getName(wakeUpLight)); end 
            fibaro:call(wakeUpLight, 'turnOff') -- turning on the device	
        end
    end



    ----- Implementation (Main) -----
    if (debug) then fibaro:debug(scene .. " - Started"); end
    local completed = false;
    while not completed do	

        -- TODO: END SCENE IF: AWAY, !SLEEPING
        local presence = fibaro:getGlobalValue("Presence");
        local activity = fibaro:getGlobalValue("Activity");
        if ( fibaro:getGlobalValue("Presence") ~= "Home"  or  
             fibaro:getGlobalValue("Activity") ~= "Sleeping" )
        then
            if (debug) then fibaro:debug(scene .. " - Aborting: incorrect Presence (" .. presence .. ") or Activity (" .. activity .. ")"); end
            fibaro:abort();
        else
            ----- Get Wakeup Time -----
            local wakeUpTime_Hours = tonumber(fibaro:getGlobal('Time_WakeUp_Hour'));			-- Integer value representing the hours of the time
            local wakeUpTime_Minutes = tonumber(fibaro:getGlobal('Time_WakeUp_Minute'));		-- Integer value representing the minutes of the time
        
            -- Calculate scene start time based on duration
            local minutes = levelsteps * diminterval;
            local start_Minutes = (wakeUpTime_Minutes > start_Minutes and wakeUpTime_Minutes - start_Minutes or wakeUpTime_Minutes + 60 - start_Minutes);
            local start_Hours = (wakeUpTime_Minutes > start_Minutes and wakeUpTime_Hours  or wakeUpTime_Hours + 1);
        
            local currentTime = os.date("*t");
            
            local wakeUpTime = os.time{year=currentTime.year, month=currentTime.month, day=(currentTime.hour > 21 and currentTime.day + 1 or currentTime.day), hour=start_Hours, minutes=start_Minutes};         
        
            if(os.time() > wakeUpTime)
            then  -- WAKE ME !!!
                increaseLight(wakeUpLight);
                
                handOver();		  

                completed = true;	 
            end 
        end

        fibaro:sleep(checkInterval*60*1000); -- give the system some breathing space
    end 

    if (debug) then fibaro:debug(scene .. " - Ended"); end
end