--[[ 
%% autostart 
%% properties 
%% globals 
--]] 

local debug = true; 
local interval = 60000;		-- Check every 10 minutes

local completed = false
while not completed do 

	completed = true;
	fibaro:sleep(interval); 
end 
