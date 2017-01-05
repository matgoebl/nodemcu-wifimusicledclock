NodeMCU-WifiMusicLedClock
=========================
(c) 2015-2016 Matthias Goebl <matthias.goebl@goebl.net>  
Published under the MIT License.

A gadget that uses a ring of ws2812 RGB LEDs to display the time or a running light,
plays melodies, calls HTTP trigger on a button press and provides an http API.


Hardware
---------

- Modules:
 - Wemos.cc D1 mini
 - WS2812 LED ring
- Circuitry:
 - GPIO0/D3: "MODE" Button to GND
 - GPIO15/D8: "SELECT" Button to Vcc
 - GPIO2/D4: 24-led ws2812 via 330R
 - GPIO4/D2: Speaker to Vcc via 100R (optional)
 - GPIO12/D6: data pin of DS18B20 one-wire temperature sensor (optional)
 - GPIO14/D5: RC-circuit with photo sensor: LDR to Vcc and 10uF to GND (optional)

![first two prototypes](wifimusicledclocks.jpg?raw=true "first two prototypes")

Software
--------
- [NodeMCU](https://github.com/nodemcu/nodemcu-firmware), tested with the build
 [nodemcu-master-25-modules-2016-06-04-14-47-40-integer.bin](https://github.com/matgoebl/nodemcu-wifimusicledclock/releases/download/v2.0/nodemcu-master-25-modules-2016-06-04-14-47-40-integer.bin)
 (equal to tag [1.5.1-master_20160603](https://github.com/nodemcu/nodemcu-firmware/releases/tag/1.5.1-master_20160603))
 using the [NodeMCU custom build service](http://nodemcu-build.com/) from [master on 2016-06-04](https://github.com/nodemcu/nodemcu-firmware/commit/cdaf6344457ae427d8c06ac28a645047f9e0f588)
 integer flavour with SSL and those modules adc,bit,cjson,coap,crypto,dht,enduser_setup,file,gpio,http,i2c,mdns,mqtt,net,node,ow,pwm,rtcfifo,rtcmem,rtctime,sntp,tmr,uart,wifi,ws2812
- [ESPTool](https://github.com/themadinventor/esptool)
- [NodeMCU-Uploader with autobaud fix](https://github.com/matgoebl/nodemcu-uploader), [upstream version](https://github.com/kmpm/nodemcu-uploader)
- [luatool with binary mode via network](https://github.com/matgoebl/luatool)
- The *.lua files here, starts up with init.lua

### Install
    make ESPDEV=/dev/ttyUSB0 flash
    make ESPDEV=/dev/ttyUSB0 bootstrap
    make ESPCONN=esp:8266 install

### Install on Windows
- Flash [base nodemcu firmware](https://github.com/matgoebl/nodemcu-wifimusicledclock/releases/download/v2.0/nodemcu-master-25-modules-2016-06-04-14-47-40-integer.bin)
 using [NodeMCU Flasher](https://github.com/nodemcu/nodemcu-flasher/raw/master/Win32/Release/ESP8266Flasher.exe)
- Format the filesystem using 
 [ESPlorer](http://esp8266.ru/esplorer-latest/?f=ESPlorer.zip)
- Upload [init.lua](https://raw.githubusercontent.com/matgoebl/nodemcu-wifimusicledclock/master/init.lua) and
 [update.lua](https://raw.githubusercontent.com/matgoebl/nodemcu-wifimusicledclock/master/update.lua)
 using ESPlorer
- Set the WiFi config by sending the following with with ESPlorer: (insert your SSID and the corresponding WPA key)
  `file.open("config.lua","w+") file.write('cfg={ssid="XXX",key="XXX"}') file.close()`
- Force update by sending the following with with ESPlorer:
  `file.open("autostart.lua","w+") file.write('dofile("update.lua")') file.close() node.restart()`
- After the update, re-enable your custom user-script:
  `file.rename("user.lua.old","user.lua")'

User Interface
==============
- Left/White Button: "MODE"
 - Short press (50-300ms): Next Mode
 - Longer press (300-1000ms): Previous Mode
 - Very long press (>3000ms): Reset
- Right/Blue Button: "SELECT"
 - Short press (50-300ms): Select next function
 - Longer press (300-1000ms): Select previous function
 - Long press (1000-3000ms): Select special function
- Small Reset Button (on Wemos Board)


Display Modes
-------------
"MODE" toggles through all modes.

1. Clock & IoT
 - Special switches to demo mode (one way, back to normal mode with 3x "MODE")
 - Next/prev calls the configured IoT URL
 - The URL may contain a %d, %d will be 1/2 for short/longer press (indicated with 1/2 blue leds)
2. Music
 - "SELECT" changes the melody
3. Running Lights
 - "SELECT" changes the pattern
 - Special runs the current pattern in reverse direction


Initial Setup
-------------
This starts up in end user setup mode with an open access point

- Press RESET, release RESET, press SELECT(blue) for 1 second (AFTER releasing RESET)
- Connect to SSID "SetupGadget.."
- Select your WIFI and enter your key
- Click OK
- Press RESET again
- It should then connect to your wlan
- Find out the IP address of your device
 - from your DHCP server
 - from the console
 - from the initial led pattern (shows the last octet of your ip)
  - the number of green leds indicates the first digit
  - the number of yellow leds indicates the second digit
  - the number of blue leds indicates the third digit
- Connect to http://IP:8266/



Network Upgrade
---------------
The gadget is able to upgrade itself directly from github using its [updater](https://github.com/matgoebl/nodemcu-wifimusicledclock/blob/master/updater.lua).

- Press RESET (or hold Left/MODE Button for 3 seconds)
- Press Left/MODE Button for 6 seconds
- After optaining an IP address, the network upgrade starts
- The number of yellow LEDs indicates the number of files to download
- After downloading each file, the corresponding LED changes to green
- In case of an error
 - The LED changes to red and the update stops
 - Press RESET to restart the process, then MODE for 6 seconds, etc.
 - You need one successful upgrade cycle to proceed (the autostart.lua file will be deleted initially to prevent half-finished upgrades)
