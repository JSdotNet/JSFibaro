--[[ 
%% autostart 
%% properties 
32 value
34 value
%% globals
Presence
--]] 

-- Description
-- Scene is triggered by motion sensor in combination with light levels detected
-- When triggered it slowly (depending on configurration) increases the light level
-- Additional support for rgbw light and relative target level is possible

-- TODO (Currently unsupported cases):	
	-- 3. Devices Already ON
    -- 4. Max Level relative to lux

----- Scene Configuration -----
local scene = "Movement lights";	-- Name of the scene

-- General:
local debug = true; 

-- Trigger Devices:
local movementSensors = { 32 };		-- Sensor (deviceId's) used to detect the movement (devine also on top)
local lightSensors = { 34 };		-- Sensor (deviceId's) used to detect the light level(lux) (devine also on top)
local lightLevel = 200;             -- The ligh level (lux) used to trigger the scene

-- Devices:
local dimLights = { 26 };			-- Dimable light (deviceId's) to control 
local rgbwLights = { 80, 19 };			-- RGBW light (deviceId's) to control

-- Dimmer configuration:
local startlevel = 0;				-- start dim level 
local maxlevelDay = 50;				-- max dim level (%) during the day 
local maxlevelNight = 30;			-- max dim level (%) during the night (or close to sleep time) 
local diminterval = 1;				-- interval time in second to wait to next dimlevel 
local levelsteps = 20;				-- Number of steps to increase to target level
-- This configuration increses the light level in 20 seconds (20 steps with 1 second interval)

function detectMovement(deviceIds)
                
    for key, deviceID in pairs(deviceIds) do
        if (tonumber(fibaro:getValue(deviceID, "value")) > 0)
        then
            if (debug) then fibaro:debug(scene .. " - Movement detected by: " .. fibaro:getName(deviceID)); end 
            return true;
        end	
    end

    return false;
end

function lightNeeded(deviceIds)
            
    for key, deviceID in pairs(deviceIds) do
        if (tonumber(fibaro:getValue(deviceID, "value")) < lightLevel)
        then
            if (debug) then fibaro:debug(scene .. " - Low light level detected by: " .. fibaro:getName(deviceID)); end 
            return true;
        end	
    end

    return false;
end


-- Scene Trigger
local startSource = fibaro:getSourceTrigger(); -- Start when at Home and Sleeping
if ( ( fibaro:getGlobalValue("Presence") == "Home" and 
       detectMovement(movementSensors)  and  
       lightNeeded(deviceIds))
    or startSource["type"] == "other") -- Support manual start
then

    ----- Only allow one instance of the current scene to run at a time -----
    if (fibaro:countScenes() > 1) then
        if (debug) then fibaro:debug(scene .. " - Aborting (Already Running) " .. dimlevel); end 
        fibaro:abort()
    end


    ----- Implementation -----
    function mergeLists(l1,l2)
        for i=1,#l2 do
            l1[#l1+1] = l2[i];
        end
        return l1;
    end

    function setColor(deviceIds) -- TODO ...

        --local color = 0;
        --local RGBWTable= {}
        --
        --local i = 1 
        --for value in string.gmatch(color,"(%d+)") do
        --	RGBWTable[i] = value
        --	i = i + 1
        --end
        --
        --for key, deviceID in pairs(deviceIds) do
        --	if (debug) then fibaro:debug(scene .. " - Set color (" .. fibaro:getName(deviceID) .. ") to: " .. color); end 
        --	fibaro:call(deviceID, "setColor", RGBWTable[1], RGBWTable[2], RGBWTable[3], RGBWTable[4]);	
        --end
    end

    --function excludeAlreadyOn() -- TODO ...
        --for key, deviceID in pairs(dimLights) do
        --	if (debug) then fibaro:debug(scene .. " - Exclude device (" .. fibaro:getName(deviceID) .. "), because already ON!"); end 
        --	if (false) then--TODO: fibaro:call(deviceID, "isON"); 	(probeer met block scene)	
        --		dimLights[key] = nil;
        --	end
        --end
        --
        --for key, deviceID in pairs(rgbwLights) do
        --	if (debug) then fibaro:debug(scene .. " - Exclude device (" .. fibaro:getName(deviceID) .. "), because already ON!" ); end 
        --	if (false) then--TODO: fibaro:call(deviceID, "isON"); 	(probeer met block scene)	
        --		rgbwLights[key] = nil;
        --	end
        --end
    --end

    function getMaxLevel() -- TODO (base on lux level ???)
        
        local activity =  fibaro:getGlobalValue("Activity");
        
        if (activity == "Going to Sleep" or activity == "Sleeping" or activity == "Waking") then
            return maxlevelNight;
        else
            return maxlevelDay;
        end
    end

    function increaseLights(deviceIds)
        local dimlevel; 
        local targetlevel = getMaxLevel();

        if (targetlevel > 100) then targetlevel = 100; end 
        if (startlevel > targetlevel) then startlevel = targetlevel; end 

        local increasePerStep = math.ceil((targetlevel - startlevel) / levelsteps);

        if (debug) then fibaro:debug(scene .. " - Increase Started"); end
        for level = startlevel, targetlevel, increasePerStep do 
            
            dimlevel = level; 
            if (dimlevel > 100) then -- Prevent Level above 100%
                dimlevel = 100; 
            end 
            
            setLevel(deviceIds, dimlevel); 
            
            fibaro:sleep(diminterval*1000);
        end 
    end

    function setLevel(deviceIds, dimlevel)
        for key, deviceID in pairs(deviceIds) do
        
            local rgbw = false;
            local currentLevel = fibaro:getValue(deviceID, "value"); 
      		if (currentLevel == nil) then
                rgbw = true;
        		currentLevel = fibaro:getValue(deviceID, "brightness"); 
            end
            
            if (tonumber(currentLevel) < dimlevel) then
                if (debug) then fibaro:debug(scene .. " - Set device (" .. fibaro:getName(deviceID) .. ") dim level at: " .. dimlevel); end 
                if (rgbw) then
                    fibaro:call(deviceID, "brightness", dimlevel);
                else
                    fibaro:call(deviceID, "setValue", dimlevel);
                end
            else 
                if (debug) then fibaro:debug(scene .. " - Device (" .. fibaro:getName(deviceID) .. ") already at required dim level"); end
            end
        end
    end


    ----- Implementation (Main) -----
    if (debug) then fibaro:debug(scene .. " - Started"); end

    --excludeAlreadyOn();

    setColor(rgbwLights);
    increaseLights(mergeLists(dimLights, rgbwLights)); 

    if (debug) then fibaro:debug(scene .. " - Ended"); end
end