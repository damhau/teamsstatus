# teamsstatus

## Introduction

Python and Powershell script to scrape the presence status from Teams log file and update a Luxafor Bluetooth USB BUsy light.
The app provided by Luxafor had to be runnning on my PC and didnt work with Teams so I took the inspiration from https://github.com/EBOOZ/TeamsStatus and https://github.com/vmitchell85/luxafor-python

The powershell script (Get-TeamsStatus.ps1) get the status from the Teams log file and will send an http request to the FLask web server started with the Pyhton script (luxafor-web.py) running on a Raspbery PI (or any other device).

## Pre requesite

- Luxafor Usb busy light, I've used the bluethooth version but other should work (link: https://www.digitec.ch/en/s1/product/luxafor-bluetooth-conference-devices-18496607?gclid=CjwKCAiAs8acBhA1EiwAgRFdwyOsbsz79s-Cpoc2STCexqZk4ck40nkurKSP2XKIzSKoe7CQUnRBOBoC3cgQAvD_BwE&gclsrc=aw.ds)
- Rapsberry Pi to connect the Luxafor Light
- Windows with MS Teams and Powershell
- Linux wiht Pyhton3 and Pip3
- If you want to use the eventlog you have to run the command below in an elevated powershell prompt
```
New-EventLog -LogName Application -Source "TeamsStatus"
```

## Installation

### Linux

- connect the Luxafor USB Bluetooth dongle or usb cable

> you can check if the id is by runnning dmesg when you insert the usb connector for the luxafor busry light

```
[10807489.281366] usb 1-1.4: current rate 8436480 is different from the runtime rate 48000
[10977261.175819] usb 1-1.3: new full-speed USB device number 4 using xhci_hcd
[10977261.315509] usb 1-1.3: New USB device found, idVendor=04d8, idProduct=f372, bcdDevice= 1.00
[10977261.315525] usb 1-1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[10977261.315538] usb 1-1.3: Product: LUXAFOR BT
[10977261.315550] usb 1-1.3: Manufacturer: GREYNUT LTD
[10977261.399011] hid-led 0003:04D8:F372.0003: hidraw2: USB HID v1.11 Device [GREYNUT LTD LUXAFOR BT] on usb-0000:01:00.0-1.3/input0
[10977261.400747] hid-led 0003:04D8:F372.0003: Greynut Luxafor initialized
```

- create the file /etc/udev/rules.d/60-luxafor.rules and add the following (to allow access for non root users)

```
# add Luxafor LED flag
SUBSYSTEMS=="usb", ATTR{idVendor}=="04d8", ATTR{idProduct}=="f372", MODE:="0666"
```

- copy the python script in any folder, I've used /opt/luxafor-web/

- create the file /etc/systemd/system/luxafor-web.service and add the following

```
[Unit]
Description=Luxafor Web
After=multi-user.target
[Service]
Type=simple
Restart=always
ExecStart=/usr/bin/python3 /opt/luxafor-web/app.py
[Install]
WantedBy=multi-user.target
```

### Windows

- copy the powershells script Get-TeamsStatus.ps1 to any folder on windows, I've copied it in  %userprofile%\AppData\Local\TeamsStatus
- edit Get-TeamsStatus.ps1 and change the following parameters
  - $logType: can be either file to log to a file or eventlog to log to event log
  - $webhookUrl: the full url of the webhook running on your Raspberssy Pi. for me it is "http://192.168.1.34:8000/webhook"
  - 

