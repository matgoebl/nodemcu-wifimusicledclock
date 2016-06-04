NodeMCU-WifiMusicLedClock
=========================
(c) 2015-2016 Matthias Goebl <matthias.goebl@goebl.net> 
Published under the MIT License.

A gadget that uses a ring of ws2812 RGB LEDs to display the time or a running light,
plays melodies, calls HTTP trigger on a button press and provides a http API.


Hardware
---------

- Modules:
 - Wemos.cc D1 mini
 - WS2812 LED ring
- Circuitry:
 - GPIO0: "MODE" Button to GND
 - GPIO15: "SELECT" Button to Vcc
 - GPIO2: 24-led ws2812 via 330R
 - GPIO4: Speaker to Vcc via 100R


Software
--------
- [NodeMCU](https://github.com/nodemcu/nodemcu-firmware), tested with [NodeMCU custom build](http://nodemcu-build.com/) from [master on 2016-06-04](https://github.com/nodemcu/nodemcu-firmware/commit/cdaf6344457ae427d8c06ac28a645047f9e0f588)
with SSL and those modules adc,bit,cjson,coap,crypto,dht,enduser_setup,file,gpio,http,i2c,mdns,mqtt,net,node,ow,pwm,rtcfifo,rtcmem,rtctime,sntp,tmr,uart,wifi,ws2812
- [luatool with binary mode via network](https://github.com/matgoebl/luatool)
- The *.lua files here, starts up with init.lua

### Install
    make ESPDEV=/dev/ttyUSB0 format bootstrap reset
    make ESPCONN=esp:8266 install


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
This starts up in a default accesspoint mode, also useful as failsafe access.

- Press RESET, release RESET, press SELECT(blue) for 1 second (AFTER releasing RESET)
- Connect to SSID "ESP8266_*" with key "NodeMCU!"
- Open http://192.168.82.1:8266
- At Config enter:
 - SSID <your SSID>, press save
 - Change to key, enter <key>, press save
- Check http://192.168.82.1:8266/cfg
- Reset
- It should then connect to your wlan (press 4x"MODE" to update status in IoT Mode).
