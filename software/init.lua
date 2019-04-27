--Ground pin 0 to prevent autostart
gpio.mode(0,gpio.INPUT,gpio.PULLUP)
if( gpio.read(0) == gpio.HIGH ) then
  print("Starting main.lua")
  dofile("main.lua")
  main:start()
else
  print("Not starting main.lua")
end
