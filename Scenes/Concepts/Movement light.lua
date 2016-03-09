--[[ 
%% autostart 
%% properties 
%% globals 
--]] 

-- TODO: Start ONLY if alle these are met:
	-- At Home, 
	-- Dark 
	-- Movement (or door trigger)

-- TODO (Currently unsupported cases):
	-- 1. Movement detected on Decrease
	-- 2. Support for multiple Devices
	-- 3. Devices Already ON



----- Only allow one instance of the current scene to run at a time -----
if (fibaro:countScenes() > 1) then
  fibaro:abort()
end



----- Scenario Configuration -----
local scenario = "Movement lights";	-- Name of the scenario

-- General:
local debug = true; 
local checkInterval = 10;			-- Interval time in minutes between checks if trigger conditions are met
local delay = 60 * 60				-- Delay time in minutes before lights are turned of

-- Devices:
local movementSensors { 25 };		-- Sensor (deviceId's) used to detect the movement
local dimLights = { 26 };			-- Dimable light (deviceId's) to control 
local rgbwLights = { 27 };			-- RGBW light (deviceId's) to control

-- Dimmer configuration:
local startlevel = 10;				-- start dim level 
local maxlevel = 40;				-- max dim level 
local diminterval = 3;				-- interval time in second to wait to next dimlevel 
local levelsteps = 10;				-- steps in procent to increase dim level



----- Implementation -----
function mergeLists(l1,l2)
    for i=1,#l2 do
        l1[#l1+1] = l2[i];
    end
    return l1;
end

function setColor(deviceIds)
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
	--	if (debug) then fibaro:debug(scenario .. " - Set color (" .. fibaro:getName(deviceID) .. ") to: " .. color .. " (" .. os.date() .. ")"); end 
	--	fibaro:call(deviceID, "setColor", RGBWTable[1], RGBWTable[2], RGBWTable[3], RGBWTable[4]);	
	--end
end

function setLevel(deviceIds, dimlevel)
	for key, deviceID in pairs(deviceIds) do
		if (debug) then fibaro:debug(scenario .. " - Set device (" .. fibaro:getName(deviceID) .. ") dim level at: " .. dimlevel .. " (" .. os.date() .. ")"); end 
		fibaro:call(deviceID, "setValue", dimlevel); 		
	end
end


function excludeAlreadyOn()
	--for key, deviceID in pairs(dimLights) do
	--	if (debug) then fibaro:debug(scenario .. " - Exclude device (" .. fibaro:getName(deviceID) .. "), because already ON!" .. " (" .. os.date() .. ")"); end 
	--	if (false) then--TODO: fibaro:call(deviceID, "isON"); 	(probeer met block scene)	
	--		dimLights[key] = nil;
	--	end
	--end
	--
	--for key, deviceID in pairs(rgbwLights) do
	--	if (debug) then fibaro:debug(scenario .. " - Exclude device (" .. fibaro:getName(deviceID) .. "), because already ON!" .. " (" .. os.date() .. ")"); end 
	--	if (false) then--TODO: fibaro:call(deviceID, "isON"); 	(probeer met block scene)	
	--		rgbwLights[key] = nil;
	--	end
	--end
end

function increaseLight(deviceIds)
	local dimlevel; 

	if (maxlevel > 100) then maxlevel = 100; end 
	if (startlevel > maxlevel) then startlevel = maxlevel; end 

	if (debug) then fibaro:debug(scenario .. " - Increase Started at: " .. os.date()); end
	for level = startlevel, maxlevel, levelsteps do 
		
		dimlevel = level; 
		if (dimlevel > 100) then -- Prevent Level above 100%
			dimlevel = 100; 
		end 
		
		setLevel(deviceIds, dimlevel); 
		
		fibaro:sleep(diminterval*1000); 
	end 
end

function decreaseLight(deviceIds)
	local dimlevel; 

	startlevel = fibaro:call(light, "getValue", dimlevel) 

	if (debug) then fibaro:debug(scenario .. " - Decrease Started at: " .. os.date()); end
	for level = startlevel, 0, -levelsteps do 
		
		dimlevel = level; 
		
		if (dimlevel < 0) then -- Prevent Negative values
			dimlevel = 0; 			
		end 
		
		setLevel(deviceIds, dimlevel); 
		
		if (dimlevel = 0) then -- Make sure devices are fully off	
			for key, deviceID in pairs(deviceIds) do
				if (debug) then fibaro:debug(scenario .. " - TurnOff device: " .. fibaro:getName(deviceID) .. " (" .. os.date() .. ")"); end 
				fibaro:call(deviceID, 'turnOFF');
			end
		end

		fibaro:sleep(diminterval*60*1000); 
	end 
end



----- Implementation (Main) -----
if (debug) then fibaro:debug(scenario .. " - Started at: " .. os.date()); end

excludeAlreadyOn();

setColor(rgbwLights);
increaseLights(mergeLists(dimLights, rgbwLights));

repeat
	fibaro:sleep(checkInterval*60*1000);  -- give the system some breathing space

    -- then check it all again...
    local motion, mTime = fibaro:get(motionID, 'value'); -- TODO: CHECH ALL MOTION SENSORS
	if (debug) then fibaro:debug(scenario .. " - Variable: motion = " .. motion); end 
	if (debug) then fibaro:debug(scenario .. " - Variable: mTime = " .. mTime); end 

    motion = tonumber(motion);
    mTime = os.time() - mTime -- convert this to number of seconds ago.
while(motion > 0 || mTime < delay*60*1000)

decreaseLights(mergeLists(dimLights, rgbwLights));

if (debug) then fibaro:debug(scenario .. " - Ended at: " .. os.date()); end