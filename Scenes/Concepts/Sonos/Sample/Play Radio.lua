local IPaddress = '192.168.1.106'
local action = 'SetAVTransportURI'
local server_url = IPaddress .. ':1400/MediaRenderer/AVTransport/Control'
local servicetype = 'urn:schemas-upnp-org:service:AVTransport:1'
local radioName = 'Radio 2'
local arguments = '<InstanceID>0</InstanceID>,<CurrentURI>x-rincon-mp3radio://icecast.omroep.nl/radio2-sb-mp3</CurrentURI>,<CurrentURIMetaData><DIDL-Lite xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/" xmlns:r="urn:schemas-rinconnetworks-com:metadata-1-0/" xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/"><item id="R:0/0/0" parentID="R:0/0" restricted="true"><dc:title>' .. radioName .. '</dc:title><upnp:class>object.item.audioIte m.audioBroadcast</upnp:class><desc id="cdudn" nameSpace="urn:schemas-rinconnetworks-com:metadata-1-0/">SA_RINCON65031_</desc></item></DIDL-Lite></CurrentURIMetaData>'
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
os.execute ('curl -s -X POST -H "SOAPAction: ' .. servicetype .. '#' .. action .. '" -d @/tmp/req.lua ' .. server_url )
fibaro:call(33, "pressButton", "1");