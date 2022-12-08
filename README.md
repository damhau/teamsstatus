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

- copy the python script in 

### Windows

- copy the powershells script Get-TeamsStatus.ps1 to any folder on windows, I've copied it in  %userprofile%\AppData\Local\TeamsStatus
- edit Get-TeamsStatus.ps1 and change the following parameters
  - $logType: can be either file to log to a file or eventlog to log to event log
  - $webhookUrl: the full url of the webhook running on your Raspberssy Pi. for me it is "http://192.168.1.34:8000/webhook"
  - 

