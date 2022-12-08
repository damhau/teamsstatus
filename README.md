# Teams Status

## Introduction

Python and Powershell script to scrape the presence status from Teams log file and update a Luxafor Bluetooth USB BUsy light.
The app provided by Luxafor had to be runnning on my PC and didnt work with Teams so I took the inspiration from https://github.com/EBOOZ/TeamsStatus and https://github.com/vmitchell85/luxafor-python

The powershell script (Get-TeamsStatus.ps1) get the status from the Teams log file and will send an http request to the FLask web server started with the Pyhton script (luxafor-web.py) running on a Raspbery PI (or any other device).

> Keep in mind that there is no security for the web endpoint exposed by the Python script, this is expected to be run in a trusted network.

## Presence state and light color

The default configuration of the powershell script will process the following event:

- If you are **in a call** the light will be **red**
- If you are **not in a call** the light will be **green**
- If your presence is **do not disturb** the light will be **red**

> You can fine tune this from line 214 to 267 in the powershell script.

## Pre requesite

- Luxafor Usb busy light, I've used the bluethooth version but other should work (link: https://www.digitec.ch/en/s1/product/luxafor-bluetooth-conference-devices-18496607?gclid=CjwKCAiAs8acBhA1EiwAgRFdwyOsbsz79s-Cpoc2STCexqZk4ck40nkurKSP2XKIzSKoe7CQUnRBOBoC3cgQAvD_BwE&gclsrc=aw.ds)
- Rapsberry Pi to connect the Luxafor Light
- Windows with MS Teams and Powershell
- Linux wiht Pyhton3 and Pip3
- If you want to use the eventlog you have to run the command below in an **elevated** powershell prompt
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
- the flask web server will listen to 8080, if you need to change it update the varaible PORT at line 21 in the script.

- cd to your folder (eg. /opt/luxafor-web/)

- install PyWinUSB and Flask

```
pip3 install PyWinUSB Flask
```

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
- enable and start the service

```
systemctl enable luxafor-web
systemctl start luxafor-web
```

- check if the service started sucesfully

```
root@raspberrypi:/opt/luxafor-web# systemctl status luxafor-web

● luxafor-web.service - Luxafor Web
   Loaded: loaded (/etc/systemd/system/luxafor-web.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2022-12-08 12:57:08 CET; 1s ago
 Main PID: 6175 (python3)
    Tasks: 2 (limit: 4915)
   Memory: 11.2M
   CGroup: /system.slice/luxafor-web.service
           └─6175 /usr/bin/python3 /opt/luxafor-web/luxafor-web.py

Dec 08 12:57:08 raspberrypi systemd[1]: Started Luxafor Web.
Dec 08 12:57:09 raspberrypi python3[6175]:  * Serving Flask app "app" (lazy loading)
Dec 08 12:57:09 raspberrypi python3[6175]:  * Environment: production
Dec 08 12:57:09 raspberrypi python3[6175]:    WARNING: Do not use the development server in a production environm
Dec 08 12:57:09 raspberrypi python3[6175]:    Use a production WSGI server instead.
Dec 08 12:57:09 raspberrypi python3[6175]:  * Debug mode: off
Dec 08 12:57:09 raspberrypi python3[6175]:  * Running on http://0.0.0.0:8000/ (Press CTRL+C to quit)
```
- you can test the webook with the following command, this should switch the led to red.

```
curl -X POST http://localhost:8000/webhook -H 'Content-Type: application/json' -d '{"color":"red"}'
```

### Windows

- copy the powershells script Get-TeamsStatus.ps1 to any folder on windows, I've copied it in  %userprofile%\AppData\Local\TeamsStatus

- edit Get-TeamsStatus.ps1 and change the following parameters
  - $logType: can be either file to log to a file or eventlog to log to event log
  - $webhookUrl: the full url of the webhook running on your Raspberssy Pi. for me it is "http://192.168.1.34:8000/webhook"

- open a powershell prompt and run the script with debug mode to check that everyhitng works
```
cd $env:USERPROFILE\AppData\Local\TeamsStatus
.\Get-TeamsStatus.ps1 -debugEnabled $true
12/08/2022 13:03:11 - Teams Status started
12/08/2022 13:03:11 - Processing Teams log file: C:\Users\Damien\AppData\Roaming\Microsoft\Teams\logs.txt
12/08/2022 13:03:11 - Status: Available
12/08/2022 13:03:11 - Activity: Not in a call
12/08/2022 13:03:11 - Wehook http://192.168.1.34:8000/webhook called
12/08/2022 13:03:11 - Wehook http://192.168.1.34:8000/webhook called
12/08/2022 13:03:16 - Status: Available
12/08/2022 13:03:16 - Activity: Not in a call
12/08/2022 13:03:21 - Status: Available
12/08/2022 13:03:21 - Activity: Not in a call
```

> you should be able to change your presence to "do not disturb" in Teams and the light should turn to red.

### Windows - Install a Service

- download nssm from https://github.com/EBOOZ/TeamsStatus/raw/main/nssm.exe and copy it to %userprofile%\AppData\Local\TeamsStatus
- start a elevated PowerShell prompt, browse to %userprofile%\AppData\Local\TeamsStatus and run the following command:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
Unblock-File .\Get-TeamsStatus.ps1
Start-Process -FilePath .\nssm.exe -ArgumentList 'install "Microsoft Teams Status Monitor" "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" "-command "& { . C:\Users\<username>\AppData\Local\TeamsStatus\Get-TeamsStatus.ps1 }"" ' -NoNewWindow -Wait
Start-Service -Name "Microsoft Teams Status Monitor"
```
> Don't forget to replace <username> with your username
   
- After completing the steps below, start your Teams client and verify if the status and activity is updated as expected.
- if you have used the eventlog logging type you can check the log in the event logs
 
   ![image](https://user-images.githubusercontent.com/14148364/206443660-46362977-c3a1-45a0-ae83-36c9d3eb01ba.png)
   ![image](https://user-images.githubusercontent.com/14148364/206443689-c46b926a-e938-4275-82bd-566ce79135c4.png)

   
### Thanks
   
- Thanks to EBOOZ for https://github.com/EBOOZ/TeamsStatus
- Thanks to Vince Mitchell for https://github.com/vmitchell85/luxafor-python
- Thanks to Luxafor for compiling some of the opensource tools here: https://luxafor.com/best-luxafor-open-source-projects/
   
   
