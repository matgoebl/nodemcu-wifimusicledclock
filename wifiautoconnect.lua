tmr.alarm(0, 10000, 1, function()
 if(wifi.sta.getip()==nil) then
  wifi.sta.getap(1, function(ap_list)
   if ap_list==nil then return end
   local best_ssid=nil
   local best_rssi=-999
   local best_key=""
   for bssid,params in pairs(ap_list) do
    local ssid, rssi = string.match(params, "([^,]+),([^,]+),")
    rssi = tonumber(rssi) or -999
    for i=0,9 do
     local n = i==0 and "" or i
     if cfg["ssid"..n] == ssid and rssi>best_rssi then
      best_ssid=cfg["ssid"..n]
      best_rssi=rssi
      best_key=cfg["key"..n]
     end
    end
   end
   if best_ssid~=nil then
    print("new AP:",best_ssid,best_rssi)
    wifi.sta.config(best_ssid,best_key)
   end
  end)
 end
end)
