# teamsstatus

## Introduction

Python and Powershell script to scrape the presence status from Teams log file and update a Luxafor Bluetooth USB BUsy light.
The app provided by Luxafor had to be runnning on my PC and didnt work with Teams so I took the inspiration from https://github.com/EBOOZ/TeamsStatus and https://github.com/vmitchell85/luxafor-python

The powershell script get the status from the Teams log file 

## Pre requesite

- Luxafor Usb busy light, I've used the bluethooth version but other should work (link: https://www.digitec.ch/en/s1/product/luxafor-bluetooth-conference-devices-18496607?gclid=CjwKCAiAs8acBhA1EiwAgRFdwyOsbsz79s-Cpoc2STCexqZk4ck40nkurKSP2XKIzSKoe7CQUnRBOBoC3cgQAvD_BwE&gclsrc=aw.ds)
- Rapsberry Pi to connect the Luxafor Light
