ESPCONN?=esp:8266
ESPDEV?=/dev/ttyUSB0
ESPAUTH?=""

install:
	# autostart.lua at the end
	# exclude: init.lua config.lua updater.lua
	for i in cfgedit.lua clock.lua compile.lua http.lua melody.lua modes.lua mqtt.lua nettime.lua rgb.lua twokeys.lua update.lua wifiautoconnect.lua autostart.lua; do \
	 luatool.py --ip $(ESPCONN) --auth "$(ESPAUTH)" --verbose --strip-whitespace --src $$i || exit 1; done
	for i in index.html api.js rgb.js; do \
	 luatool.py --ip $(ESPCONN) --auth "$(ESPAUTH)" --verbose --binary --src $$i; done

bootstrap:
	#nodemcu-uploader.py --port=$(ESPDEV) upload init.lua config.lua updater.lua
	for i in init.lua update.lua; do \
	 luatool.py --port $(ESPDEV) --baud 9600 --verbose --strip-whitespace --src $$i || exit 1; done

reset:
	luatool.py --port $(ESPDEV) --baud 9600 --verbose --restart

format:
	luatool.py --port $(ESPDEV) --baud 9600 --verbose --execute "file.format()"
	sleep 60

flash_nodemcu_dev:
	esptool.py --port=$(ESPDEV) write_flash 0x00000 0x00000.bin
	esptool.py --port=$(ESPDEV) write_flash 0x10000 0x10000.bin
