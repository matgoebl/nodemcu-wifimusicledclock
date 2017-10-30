ESPCONN?=esp:8266
ESPBAUD?=115200
ESPDEV?=/dev/ttyUSB0 #for WeMos D1: /dev/serial/by-id/usb-1a86_USB2.0-Serial-if00-port0
ESPAUTH?=""
NODEMCUUPLOADER=python nodemcu-uploader/nodemcu-uploader.py --port=$(ESPDEV) --baud $(ESPBAUD) #--verbose
ESPTOOL=python esptool/esptool.py --port=$(ESPDEV)
ESPCURL=curl -H "ESPAUTH: $(ESPAUTH)" -s http://$(ESPCONN)
HOSTIP?=192.168.0.1

install:
	# autostart.lua at the end
	# exclude: init.lua config.lua updater.lua
	for i in cfgedit.lua clock.lua compile.lua http.lua melody.lua modes.lua mqtt.lua rgb.lua twokeys.lua update.lua wifiautoconnect.lua owtemp.lua timer.lua autostart.lua; do \
	 luatool.py --ip $(ESPCONN) --auth "$(ESPAUTH)" --verbose --strip-whitespace --src $$i || exit 1; done
	for i in index.html api.js rgb.js; do \
	 luatool.py --ip $(ESPCONN) --auth "$(ESPAUTH)" --verbose --binary --src $$i; done

nodemcu-uploader/nodemcu-uploader.py:
	git clone https://github.com/matgoebl/nodemcu-uploader


bootstrap: nodemcu-uploader/nodemcu-uploader.py
	$(NODEMCUUPLOADER) file format
	$(NODEMCUUPLOADER) upload update.lua init.lua
	$(NODEMCUUPLOADER) file list
	$(NODEMCUUPLOADER) node restart
	#for i in updater.lua init.lua; do \
	# luatool.py --port $(ESPDEV) --baud $(ESPBAUD) --verbose --strip-whitespace --src $$i || exit 1; done

reset:
	$(NODEMCUUPLOADER) node restart
	$(NODEMCUUPLOADER) node heap
	#luatool.py --port $(ESPDEV) --baud $(ESPBAUD) --verbose --restart

format:
	$(NODEMCUUPLOADER) file format
	#luatool.py --port $(ESPDEV) --baud $(ESPBAUD) --verbose --execute "file.format()"
	#sleep 60


esptool/esptool.py:
	git clone https://github.com/themadinventor/esptool

nodemcu-master-25-modules-2016-06-04-14-47-40-integer.bin:
	wget https://github.com/matgoebl/nodemcu-wifimusicledclock/releases/download/v2.0/nodemcu-master-25-modules-2016-06-04-14-47-40-integer.bin

flash:	nodemcu-master-25-modules-2016-06-04-14-47-40-integer.bin esptool/esptool.py
	$(ESPTOOL) write_flash 0x0 nodemcu-master-25-modules-2016-06-04-14-47-40-integer.bin

erase:	esptool/esptool.py
	$(ESPTOOL) erase_flash

flash_nodemcu_dev: esptool/esptool.py
	$(ESPTOOL) write_flash 0x00000 0x00000.bin
	$(ESPTOOL) write_flash 0x10000 0x10000.bin

sizecheck:
	@echo Sizes:
	@wc -c *.lua | sort -n

localserve:
	/usr/sbin/mini_httpd -p 8280 -l /dev/stdout -d . -D

localupgrade:
	$(ESPCURL)/cfg?updateurl=http://$(HOSTIP):8280/
	$(ESPCURL)/upgrade
