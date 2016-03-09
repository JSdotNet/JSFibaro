local IPaddress = '192.168.1.106'
local action = "Pause"
local server_url = IPaddress .. ':1400/MediaRenderer/AVTransport/Control'
local servicetype = 'urn:schemas-upnp-org:service:AVTransport:1'
local arguments = '<InstanceID>0</InstanceID>,<Speed>1</Speed>'
local req = '<?xml version="1.0" encoding="utf-8"?>' .. 
'<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' ..
'<s:Body>' ..
'<u:' .. action .. ' xmlns:u="' .. servicetype .. '">' .. arguments ..
'</u:' .. action .. '>' ..
'</s:Body>' ..
'</s:Envelope>'
local file_req = io.open( "/tmp/req.lua", "w" )
file_req:write( req )
file_req:close()
a = os.execute ('curl -s -X POST -H "SOAPAction: ' .. servicetype .. '#' .. action .. '" -d @/tmp/req.lua ' .. server_url)