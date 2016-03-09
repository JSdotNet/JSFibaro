--[[
%% properties
0 value
%% globals
--]]

local schedule = {
  
  id = 0, --Change to ID of your heating schedule
  idleTemp = 0 --Temperature that will be applied when window or door is opened 
  
}

sensor = 0 --ID of Door/Window Sensor, remember to adjust triggering device

--Do not modify code below this line

local function getMethod(requestUrl, successCallback, errorCallback)
  
  local http = net.HTTPClient()
  
  http:request(requestUrl, {
      options = {
        method = 'GET'
      },
      success = successCallback,
      error = errorCallback
  })
end

local function putMethod(requestUrl, data, successCallback, errorCallback)
  
  local http = net.HTTPClient()  
  http:request(requestUrl, {
      options = {
        method = 'PUT',
        data = json.encode(data)
      },
      success = successCallback,
      error = errorCallback
  })
end

local function updateSchedule(subjectToChange)

  local url = 'http://127.0.0.1:11111/api/panels/heating/' .. subjectToChange.id
  
  getMethod(url, function(resp)
    
    if resp.status == 200 then
      print('Connection successful, status ' .. resp.status)
      
      local panel = json.decode(resp.data)
      
      if panel.properties.vacationTemperature ~= nil then

        if fibaro:getValue(sensor, "value") == '1' then
         
          panel.properties.vacationTemperature = subjectToChange.idleTemp          
          print('Setting temperature to ' .. subjectToChange.idleTemp .. 'C')
     
        else
          
          panel.properties.vacationTemperature = 0
          print('Scheduled temperature was set')  
            
        end
            
        putMethod(url, panel, function(resp)
        
          if resp.status == 200 then
            print('Change was applied')
          end
            
        end,
          
        function(err)
          print('error ' .. err)
        end
     	)
        else
          print('No value found')
        end
    else
      print('Connection failed, status ' .. resp.status)
    end
      
    end,
    
    function(err)
      print('error ' .. err)
    end
    )
  
end

updateSchedule(schedule)
