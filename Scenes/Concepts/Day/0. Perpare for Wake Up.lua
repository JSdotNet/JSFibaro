
-- Before the day start some things need to happen:
-- 1. First the bathroom should be preheated
-- 2. Then the rest of the house should heated to te required temperature.
-- Concern => Should the house be fully heated if only at home for a short while before leaving for work or ... (How to detect?)
-- 3. .... (I'm sure I will think of some more before completing this scene)

-- This scene is triggered by the wakeup time, but will start some hours before that (variable: hoursBeforeWakeup), 
-- it uses othe scene to achieve te requirements


-- TODO: Start time could be variable based on temperature increase required (???)

--[[ 
%% autostart 
%% properties 
%% globals 
--]] 


local debug = true; 

local scenario = "Wake up preperation";		-- Name of the scenario
local hoursBeforeWakeup = 1;				-- Hours before wakeup time to start the scene
local interval = 60000;						-- Check every 10 minutes


local wakeUpTime = fibaro:getGlobal('WakeUpTime');


local sceneIDs = {56, 78, 29};			-- The Scene's that should be started



function relativeTime(time, correction) -- Calculate relative Time
	return string.format("%02d", string.sub(time, 0, 2) - correction  - hoursBeforeWakeup) .. ":" .. string.format("%02d", string.sub(time, 3, 2));
end

function startScenes(sceneIDs)

	for key, sceneID in pairs(sceneIDs) do		
	 		  
			if (debug) then fibaro:debug(scenario .. " - Starting Scene: " + fibaro:getName(sceneID) + " (" + fibaro:getRoomName(fibaro:getRoomID(deviceID) + ")."); end 

			fibaro:startScene(sceneID)
	end	
end


local start = relativeTime(wakeUpTime, hoursBeforeWakeup);
if (debug) then fibaro:debug(scenario .. "- WILL be started at: " .. start); end

local completed = false;
while not completed do 

	-- TODO: Detect thet starting time has been reached
	local currentDate = os.date("*t"); 
	
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

	  startScenes(sceneIDs);

	  completed = true;	 
	end 

	fibaro:sleep(interval); 
end