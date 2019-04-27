--main.lua

-- ADC must be in external ADC mode
if adc.force_init_mode(adc.INIT_ADC) then
  node.restart()
  return -- don't bother continuing, the restart is scheduled
end


dofile("ultrasonic.lua")
dofile("wifi-connect.lua")
dofile("mqtt.lua")

main={
  wifiDone=false,
  measurementDone=false,
  mqClient=nil,
  mqConnected=false,
  battery_mv=0,
  distance_cm=0
}


function main:sleep()
  if gpio.read(0) == gpio.LOW then
    print("GPIO 0 held low. Will not sleep")
  else
    node.dsleep(3600000000,2) -- 1 hour
  end
end

function main:checkState()
  if main.wifiDone and main.measurementDone and main.mqConnected then
    print "READY TO SEND"
    local msg
    msg = string.format("{\"level\":%d,\"battery\":%d}",main.distance_cm, main.battery_mv)
    print(msg)
    main.mqClient:publish("waterLevel", msg , 0, 0, main.sleep)
    --main:sleep()
  end
end

function main:mqConnectedCallback(client)
  main.mqClient = client
  main.mqConnected = true
  main:checkState()
end

function main:wifiCallback(status)
  if status == false then
    main:sleep()
  else
    main.wifiDone = true
    mqttConnect(main.mqConnectedCallback)
    main:checkState()
  end
end

function main:measurmentCallback( battery, distance)
  main.battery_mv = battery
  main.distance_cm = distance
  main.measurementDone=true
  main:checkState()
end

function main:start()
  main.wifiDone=false
  main.measurementDone=false
  main.mqConnected=false
  --give wifi 20 seconds to connect
  wifiConnect(20000, main.wifiCallback)
  getMeasurements(main.measurmentCallback)
end
