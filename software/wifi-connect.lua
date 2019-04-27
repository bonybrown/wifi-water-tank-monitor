
function wifiConnect(timeout, callback )
  
  dofile("settings.lua")
  local station_cfg={
    ssid=wifiSSID,
    pwd=wifiPassword,
    save=false
  }
  
  if wifi.STA_GOTIP ~= wifi.sta.status() then
    wifi.setmode(wifi.STATION)
    wifi.sta.config(station_cfg)
    wifi.sta.connect()
  end
  
  local timer = tmr.create()
  
  timer:alarm(1000, tmr.ALARM_AUTO, 
    function()
      if (wifi.STA_GOTIP == wifi.sta.status()) then
        local ip, netmask, gateway = wifi.sta.getip()
        print("Connected to " .. station_cfg.ssid .. " with ip address " .. ip)
        timer:stop()
        timer:unregister()
        callback(nil, true)
      else
        print("Attempting to connect to " .. station_cfg.ssid)
        timeout = timeout - 1000
        if timeout < 0 then
          timer:stop()
          timer:unregister()
          callback(nil, false)
        end
      end
    end
  )

end
