

-- Trigger scenario's that should be started to wake you




--[[ 
%% autostart 
%% properties 
%% globals 
--]] 

-- Start IF Home and ASLEEP 

local debug = true; 

local sceneIDs = {56, 78, 29};							-- The Scene's that should be started, example: 
															-- Start Led Strip Wakeup
															-- Start WakeUp light
															-- Open Roller shutter
															-- All bedroom lights on															
																													
local scenario = "Wake up";								-- Name of the scenario
local wakeUpTime = fibaro:getGlobal('WakeUpTime');		-- Numeric variable (for example: 7.5 = 07:30)
local interval = 60000;									-- Check every 10 minutes


function startScenes(sceneIDs)

	for key, sceneID in pairs(sceneIDs) do		
	 		  
			if (debug) then fibaro:debug(scenario .. " - Starting Scene: " + fibaro:getName(sceneID) + " (" + fibaro:getRoomName(fibaro:getRoomID(deviceID) + ")."); end 

			fibaro:startScene(sceneID)
	end	
end

while not completed do	

	local currentDate = os.date("*t"); 
	
	if ( ( ((currentDate.wday == 1 or 
		     currentDate.wday == 2 or 
		     currentDate.wday == 3 or 
		     currentDate.wday == 4 or 
		     currentDate.wday == 5 or 
		     currentDate.wday == 6 or 
		     currentDate.wday == 7) and 
		     string.format("%02d", currentDate.hour) .. ":" .. string.format("%02d", currentDate.min) == wakeUpTime) ) ) 
	then  -- Wake me up
	  if (debug) then fibaro:debug(scenario .. " - Started at: " .. os.date()); end
	  
	  startScenes(sceneIDs);

	  completed = true;	 
	end 

	fibaro:sleep(interval); 
end 



