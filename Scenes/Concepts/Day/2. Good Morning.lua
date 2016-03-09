
-- What should happen When you are actualy awake (Detect based on motion), example:
	-- 


--[[ 
%% autostart 
%% properties 
59 value					-- Value of the motion device
%% globals 
--]] 

local debug = true							-- Set to false onse the scene is working as expected
local scenario = "Goog morning";			-- Name of the scenario
local motionID = 55;						-- The id of the motion detector (eye)
local hoursBeforeWakeup = 2;				-- Hours before wakeup time to start the scene
local interval = 60000;						-- Check every 10 minutes

local sceneIDsToStop = {56, 78, 29};		-- Stop the scene that (potentialy are started by WakeUp and prepare for wakeup).
local sceneIDs = {56, 78, 29};				-- The Scene's that should be started, example: 
												-- Lights ON bedroom
												-- Lights ON to Bathroom
												-- Preheat bathroom
												-- Morning heating	
												-- Music ON											
																	
local wakeUpTime = fibaro:getGlobal('WakeUpTime');

if (debug) then fibaro:debug("Scene started: " .. scenario); end 


function relativeTime(time, correction) -- Calculate relative Time
	return string.format("%02d", string.sub(time, 0, 2) - correction  - hoursBeforeWakeup) .. ":" .. string.format("%02d", string.sub(time, 3, 2));
end

local start = relativeTime(wakeUpTime, hoursBeforeWakeup);
if (debug) then fibaro:debug(scenario .. "- WILL be started at: " .. start); end


function stopScenes(sceneIDs)

	for key, sceneID in pairs(sceneIDs) do		
	 		  
		-- TODO: Detect if scene is running ???
		if (debug) then fibaro:debug(scenario .. " - Stopping Scene: " + fibaro:getName(sceneID) + " (" + fibaro:getRoomName(fibaro:getRoomID(deviceID) + ")."); end 

		fibaro:stopScene(sceneID)
	end	
end

function startScenes(sceneIDs)

	for key, sceneID in pairs(sceneIDs) do		
	 		  
		if (debug) then fibaro:debug(scenario .. " - Starting Scene: " + fibaro:getName(sceneID) + " (" + fibaro:getRoomName(fibaro:getRoomID(deviceID) + ")."); end 

		fibaro:startScene(sceneID)
	end	
end



local completed = false;
while (not completed) do

	if ( ( ((currentDate.wday == 1 or 
		     currentDate.wday == 2 or 
		     currentDate.wday == 3 or 
		     currentDate.wday == 4 or 
		     currentDate.wday == 5 or 
		     currentDate.wday == 6 or 
		     currentDate.wday == 7) and 
		     string.format("%02d", currentDate.hour) .. ":" .. string.format("%02d", currentDate.min) == start) ) ) 
	then 
		if (debug) then fibaro:debug(scenario " - Started at: " .. os.date()); end


		local awake = false;
		while (not awake) do

			local motion = tonumber(fibaro:getValue(motionID, 'value'));

			if (motion == 1) then
				if (debug) then fibaro:debug(scenario .. " - Motion detected, you must be awake"); end 

				stopScenes(sceneIDsToStop);
				startScenes(sceneIDs);
				
				awake = true;
			end
		end
		completed = true;	 
	end 

	fibaro:sleep(interval); 
end 