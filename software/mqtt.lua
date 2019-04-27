

local mqConnected = false
local mqttConnectCallback = nil

local function mqttConnected(client)
    print("MQTT connected")
    mqConnected = true
    mqttConnectCallback(nil, client)
end

local function mqttDisconnected(client)
    mqConnected = false
    print("MQTT offline")
end

function mqttConnect(callback)
  mqttConnectCallback = callback
  mqttClient = mqtt.Client("tank", 120, mqttUser, mqttPassword)
  
  mqttClient:on("connect", mqttConnected)
  mqttClient:on("offline", mqttDisconnected)
  mqttClient:connect(mqttServerAddress, mqttPort, 0, 1)    
end
