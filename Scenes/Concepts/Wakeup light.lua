--[[ 
%% autostart 
%% properties 
%% globals 
--]] 

-- TODO: Start ONLY IF:
	-- At Home
	-- ASLEEP 



----- Only allow one instance of the current scene to run at a time -----
if (fibaro:countScenes() > 1) then
  fibaro:abort()
end



----- Scenario Configuration -----
local scenario = "Wake up light";	-- Name of the scenario

-- General:
local debug = true; 
local checkInterval = 10;			-- Interval time in minutes between checks if trigger conditions are met

-- Devices:
local wakeUpLight = 26;				-- dimable light to control 
local handOverlights = { 27, 28 };	-- If specified the scene will turn on normal light when full level is reached

-- Dimmer configuration:
local startlevel = 20;				-- start dim level 
local maxlevel = 100;				-- max dim level 
local diminterval = 2;				-- interval time in minutes to wait to next dimlevel 
local levelsteps = 10;				-- steps in procent to increase dim level



----- Implementation (Supporting Functions) -----
function increaseLight(deviceId)
	local dimlevel; 

	if (maxlevel > 100) then maxlevel = 100; end 
	if (startlevel > maxlevel) then startlevel = maxlevel; end 

	if (debug) then fibaro:debug(scenario .. " - Increase Started at: " .. os.date()); end
	for level = startlevel, maxlevel, levelsteps do 
		
		dimlevel = level; 
		
		if (dimlevel > 100) then  -- Prevent Level above 100%
			dimlevel = 100; 
		end 
		
		fibaro:call(deviceId, "setValue", dimlevel); 
		if (debug) then fibaro:debug(scenario .. " - Set dim level at: " .. dimlevel .. " (" .. os.date() .. ")"); end 
		
		fibaro:sleep(diminterval*60*1000); 
	end 
end


function handOver()
	
	if (handOverlights != nil)
	then
		if (debug) then fibaro:debug(scenario .. " - Hand over to 'main lights'"); end 
		for key, deviceID in pairs(handOverlights) do
			if (debug) then fibaro:debug(scenario .. " - Turn On: " .. fibaro:getName(deviceID)); end 
			fibaro:call(deviceID, 'turnON') -- turning on the device			
		end

		if (debug) then fibaro:debug(scenario .. " - Turn Off: " .. fibaro:getName(wakeUpLight)); end 
		fibaro:call(wakeUpLight, 'turnOFF') -- turning on the device	
	end
end



----- Implementation (Main) -----
if (debug) then fibaro:debug(scenario .. " - Started at: " .. os.date()); end
local completed = false;
while not completed do	

	-- TODO: END SCENE IF: AWAY, !SLEEPING
	if (false)
	then
		completed = true;	 

	else
		----- Get Wakeup Time -----
		local wakeUpTime_Hours = fibaro:getGlobal('WakeUpTime_Hours');			-- Integer value representing the hours of the wakeup time
		local wakeUpTime_Minutes = fibaro:getGlobal('WakeUpTime_Minutes');		-- Integer value representing the minutes of the wakeup time
	
		local currentTime = os.date("*t"); 
		local wakeUpTime = os.time{year=currentTime.year, month=currentTime.month, day=currentTime.day, hour=wakeUpTime_Hours, minutes=wakeUpTime_Minutes}("*t");
	
		if(currentTime > wakeUpTime)
		then  -- WAKE ME !!!
		  increaseLight(wakeUpLight);
		  
		  handOver();		  

		  completed = true;	 
		end 
	end

	fibaro:sleep(checkInterval*60*1000); -- give the system some breathing space
end 

if (debug) then fibaro:debug(scenario .. " - Ended at: " .. os.date()); end