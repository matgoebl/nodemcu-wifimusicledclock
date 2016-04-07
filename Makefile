ESPCONN?=esp:8266
ESPDEV?=/dev/ttyUSB0
ESPAUTH?=""

install:
	#for i in  twokeys.lua cfgedit.lua autostart.lua compile.lua; do \
	# luatool.py --ip $(ESPCONN) --auth "$(ESPAUTH)" --verbose --strip-whitespace --src $$i || exit 1; done
	luatool.py --ip $(ESPCONN) --auth "$(ESPAUTH)" --verbose --binary --src index.html

bootstrap:
	#nodemcu-uploader.py --port=$(ESPDEV) upload init.lua config.lua
	for i in init.lua config.lua; do luatool.py --port $(ESPDEV) --baud 9600 --verbose --strip-whitespace --src $$i || exit 1; done

reset:
	luatool.py --port $(ESPDEV) --baud 9600 --verbose --restart

format:
	luatool.py --port $(ESPDEV) --baud 9600 --verbose --execute "file.format()"
	sleep 60

flash_nodemcu_dev:
	esptool.py --port=$(ESPDEV) write_flash 0x00000 0x00000.bin
	esptool.py --port=$(ESPDEV) write_flash 0x10000 0x10000.bin
