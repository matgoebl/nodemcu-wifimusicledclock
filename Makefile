ESPCONN?=esp:8266
ESPDEV?=/dev/ttyUSB0

install:
	for i in handle_http_basic.lua rgb.lua melody.lua nettime.lua clock.lua modes.lua twokeys.lua cfgedit.lua ;do luatool.py --ip $(ESPCONN) -f $$i -v -W; done
	for i in autostart.lua compile.lua;do luatool.py --ip $(ESPCONN) -f $$i -v -W; done
	luatool.py --ip $(ESPCONN) -d -v -W -f index.html -B

bootstrap:
	nodemcu-uploader.py --port=$(ESPDEV) upload init.lua config.lua

flash_nodemcu_dev:
	esptool.py --port=$(ESPDEV) write_flash 0x00000 0x00000.bin
	esptool.py --port=$(ESPDEV) write_flash 0x10000 0x10000.bin
