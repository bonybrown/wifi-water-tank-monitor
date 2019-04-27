local trig=5
local echo=6
local enable=3

local low = -1
local measure_count=0
local distance_measurement_count = 0
local measurement_done_callback = nil
local battery_sum = 0
local distance_sum = 0

local timer = nil

local function endMeasurement()
  gpio.trig(echo, "none")
  gpio.write(enable, gpio.HIGH)
  timer:stop()
  timer:unregister()
end


local function reportMeasurement()
  endMeasurement()
  local avg_distance = distance_sum / distance_measurement_count
  local avg_battery = battery_sum / measure_count
  print("Average distance: ", avg_distance)
  print("Average voltage: ", avg_battery)
  --sleep()
  measurement_done_callback( nil, avg_battery, avg_distance)
end

local function onEchoChange(level, when, eventcount)
  if level == gpio.HIGH and low == -1 then
    low = when
  end
  if level == gpio.LOW and low then
    local duration= when - low
    low = -1
    local distance_cm = duration / 58
    if distance_cm < 300 then
      distance_sum = distance_sum + distance_cm
      distance_measurement_count = distance_measurement_count + 1
      print("distance=", distance_cm)
      if distance_measurement_count > 10 then
        reportMeasurement()
      end
    end
  end
end



local function measure()
  local battery_mv = adc.read(0) * 7.0 --convert to millivolts
  battery_sum = battery_sum + battery_mv
  measure_count = measure_count + 1
  print("voltage=", battery_mv )
  print("count=", measure_count )
  if measure_count > 20 then
    reportMeasurement()
  else
    gpio.write(trig, gpio.HIGH)
    tmr.delay(10)
    gpio.write(trig, gpio.LOW)
  end
end


function getMeasurements(callback)
  print("Starting measurement cycle")
  gpio.trig(echo, "both", onEchoChange)
  measurement_done_callback = callback
  measure_count = 0
  distance_sum = 0
  battery_sum = 0
  distance_measurement_count = 0
  gpio.write(enable, gpio.LOW)
  timer = tmr.create()
  timer:register(300, tmr.ALARM_AUTO, measure)
  timer:start()
end

gpio.mode(trig, gpio.OUTPUT)
gpio.mode(enable, gpio.OPENDRAIN)
gpio.write(enable, gpio.HIGH)
gpio.write(trig, gpio.LOW)
gpio.mode(echo, gpio.INPUT)


--wake_up()
