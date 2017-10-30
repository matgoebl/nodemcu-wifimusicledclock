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
 integer flavour with SSL and the following modules: adc, bit, cjson, coap, crypto, dht, enduser_setup, file, gpio, http, i2c, mdns, mqtt, net, node, ow, pwm, rtcfifo, rtcmem, rtctime, sntp, tmr, uart, wifi, ws2812
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
  `file.rename("user.lua.old","user.lua") node.restart()`

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
- In case of an error, the LED changes to red and the update stops
  - Press RESET to restart the process, then MODE for 6 seconds, etc.
  - You need one successful upgrade cycle to proceed (the autostart.lua file will be deleted initially to prevent half-finished upgrades)


Custom extension modules
========================
The gadget allows custom extension modules in addition to its basic functionality.

To add your own modules do the following:
- Create and upload a file named `user.lua`: It is meant to register own modes and commands.
  - Please note: after an upgrade, the file will be renamed to `user.lua.old`.
  - In case of problems with custom modules you can perform an upgrade to disable it
- Create and upload any number of module files.

See [user.lua](https://github.com/matgoebl/nodemcu-wifimusicledclock/blob/master/user-servo/user.lua) for an example registration.

Custom mode API
---------------
The `modes` table contains the list of usable modes, that can be toggled using the "MODE" key.
The [default](https://github.com/matgoebl/nodemcu-wifimusicledclock/blob/master/modes.lua#L1) is
`{"clock","timer","melody","rgb"}`.

You can insert an custom modules by adding it there: `table.insert(modes,3,"servo")`

When the mode _servo_ is started, the following happens:
 1. The file _servo_.lua is loaded.
 2. The code is expected to return a table containing at least a `start()` and `stop()` function (and optionally `key()`).
 3. The `start()` function is called.
 4. When the "SELECT" key is pressed, `key(n)` is called. n is set to 1 for short press ("next"), -1 for longer press ("prev"), 0 for long press ("special").
 5. Before changing to another mode `stop()` is called.

See [servo.lua](https://github.com/matgoebl/nodemcu-wifimusicledclock/blob/master/user-servo/servo.lua) for an example user mode.
 

Commands API
------------
The global table `cmd` contains a map of available commands: The keys are their names, the values are functions.

Example:
    function cmd.beep(p)
     beep(tonumber(p.f),tonumber(p.d))
     return({})
    end

The http/mqtt arguments are provided as table, the returned table is converted to JSON.

A command _foobar_ can be called
 1. via http:
   - Request: HTTP GET `http://ESPIP:8266/foobar?a=123&b=xzy`
   - The response is returned as JSON in the reply body.
 2. via MQTT:
   - Publish the request as `{"a":123,"b":"xzy"}` to `ESPMQTTID/cmd/foobar`
   - The response is published as JSON in `ESPMQTTID/res/foobar`

Status API
----------
If you just want to publish some values, you could add them to the global table `status` that can be accessed with  `GET http://ESPIP:8266/status` or `{}` to `ESPMQTTID/cmd/status`.

Configuration API
-----------------
The configuration is kept in a global table `cfg`, containing map of strings (numbers are handled as strings for simplicity).
It is read from `config.lua` at startup.
You can add arbitrary configuration items.
The config items can be changed with the command `cfg`, e.g. `GET http://ESPIP:8266/cfg?ssid=foo&key=bar` or `{"ssid":"foo","key":"bar"}` to `ESPMQTTID/cmd/cfg`.

Current configuration parameters:
 - ssid
 - key
 - ssid2
 - key2
 - ssid3
 - key3
 - trigurl
 - auth
 - mquser
 - mqpass
 - mqhost
 - mqport
 - mqtls
 - mqid
 - updateurl
 - lednum
 - leddim_day
 - leddim_night
 - leddim_threshold
 - returnmain
 - ntphost



Memory Considerations
=====================

Unfortunately, TLS (for HTTPS and MQTT) is quite RAM (heap) consuming and ESP RAM is tight.


Updater
-------

The updater fetches all lua scripts directly from github via HTTPS by default
(see Makefile for a local upgrade)/
It runs after a reboot, without any scripts running.
Tests showed, that 17k heap is not enough for GET via HTTPS, but 34k works.

The HTTP header size from github is about 840 bytes (tested at 2017-10-30 with curl).
Processing a 7k https body temporarily reduces the heap by 16k.
The maximum download size is slightly more than 7k, so taking 7k as maximum script size
should be a save choice for a working update.
Use `make sizecheck` to calculate script sizes.
