local ow_pin=6 -- GPIO12

--cmd.temp = function(c,p)
-- local t=ds18b20_read()
-- return ({temp=t})
--end

--function ds18b20_read(ow_pin)
  local ow_pin=6
  local result = nil
  ow.setup(ow_pin)
  local flag = false
  ow.reset_search(ow_pin)
  local count = 0
  repeat
    count = count + 1
    addr = ow.search(ow_pin)
    tmr.wdclr()
  until((addr ~= nil) or (count > 100))
  ow.reset_search(ow_pin)
  if(addr == nil) then
    return result
  end
  local crc = ow.crc8(string.sub(addr,1,7))
  if (crc == addr:byte(8)) then
    if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
      -- print("Device is a DS18S20 family device.")
      ow.reset(ow_pin)
      ow.select(ow_pin, addr)
      ow.write(ow_pin, 0x44, 1)
      -- tmr.delay(1000000)
      present = ow.reset(ow_pin)
      ow.select(ow_pin, addr)
      ow.write(ow_pin,0xBE,1)
      -- print("P="..present)
      -- local data = nil
      local data = string.char(ow.read(ow_pin))
      for i = 1, 8 do
        data = data .. string.char(ow.read(ow_pin))
      end
      -- print(data:byte(1,9))
      crc = ow.crc8(string.sub(data,1,8))
      -- print("CRC="..crc)
      if (crc == data:byte(9)) then
        local t = (data:byte(1) + data:byte(2) * 256)
        if (t > 32767) then
          t = t - 65536
        end

        if (addr:byte(1) == 0x28) then
          t = t * 625  -- DS18B20, 4 fractional bits
        else
          t = t * 5000 -- DS18S20, 1 fractional bit
        end

        t = t * 100 -- do nothing
        return t
      end
      tmr.wdclr()
    else
    -- print("Device family is not recognized.")
    end
  else
  -- print("CRC is not valid!")
  end
  return result
--end
