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
- [NodeMCU](https://github.com/nodemcu/nodemcu-firmware), tested with `NodeMCU 1.5.1 build 20160121 powered by Lua 5.1.4 on SDK 1.5.1(e67da894)`
- The *.lua files here, starts up with init.lua

### Install
    make bootstrap
    make install


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

1. Music
 - "SELECT" changes the melody
2. Running Lights
 - "SELECT" changes the pattern
 - Special runs the current pattern in reverse direction
3. Clock
 - "SELECT" switches to demo mode (one way, back to normal mode with 4x "MODE")
4. IoT
 - Display WLAN status: 1x green: connected  2x red: no connection/no ip address
 - "SELECT" calls the configured IoT URL
 - The URL may contain a %d, %d will be 1/3/2 for short/longer/long press (indicated with 1/3/2 blue leds)


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
