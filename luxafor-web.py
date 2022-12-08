from flask import Flask, request
import usb.core
import usb.util
import sys
import argparse

app = Flask(__name__)


import usb.core
import usb.util
import sys
import argparse

DEVICES = []
ACTION = None
LED = None

HEX = None
RED = None
GREEN = None
BLUE = None
SPEED = None
REPEAT = None
WAVE = None
PATTERN = None


def set_luxafor(color_name):
    global RED
    global GREEN
    global BLUE
    global DEVICE
    global RED
    global GREEN
    global BLUE
    global SPEED
    global REPEAT
    global WAVE
    global PATTERN
    global LED
    global HEX

    setupDevices()

    DEVICE = 1
    SPEED = 0
    REPEAT = 0
    WAVE = 0
    PATTERN = 0
    LED = 255
    HEX = 0
    
    if color_name == "green":
        RED = 0
        GREEN = 255
        BLUE = 0
    if color_name == "red":
        RED = 255
        GREEN = 0
        BLUE = 0
    if color_name == "blue":
        RED = 0
        GREEN = 0
        BLUE = 255
    if color_name == "off":
        RED = 0
        GREEN = 0
        BLUE = 0


    if HEX:
        rgb = hex_to_rgb(HEX)
        RED = rgb[0]
        GREEN = rgb[1]
        BLUE = rgb[2]


    setColor()


def hex_to_rgb(value): # http://stackoverflow.com/a/214657
    value = value.lstrip('#')
    lv = len(value)
    return tuple(int(value[i:i + lv // 3], 16) for i in range(0, lv, lv // 3))

def setupDevices():
    global DEVICES

    for flag in usb.core.find(find_all=True, idProduct=0xf372):
        DEVICES.append(flag)

    # Device found?
    if len(DEVICES) < 1:
        raise ValueError('Device(s) not found')

    # Linux kernel sets up a device driver for USB device, which you have to detach.
    # Otherwise trying to interact with the device gives a 'Resource Busy' error.
    for flag in DEVICES:
        try:
            flag.detach_kernel_driver(0)
        except Exception:
            pass
     
        #flag.set_configuration()

def writeValue(values):
    if (DEVICE > 0):
        doWriteValue(DEVICES[DEVICE-1], values)
        return

    for flag in DEVICES:
        doWriteValue(flag, values)

def doWriteValue(target, values):
    # Run it twice to ensure it works.
    target.write(1, values)
    target.write(1, values)

def setPattern():
    writeValue( [6,PATTERN,REPEAT,0,0,0,0] )

def setWave():
    writeValue( [4,WAVE,RED,GREEN,BLUE,0,REPEAT,SPEED] )

def setStrobe():
    writeValue( [3,LED,RED,GREEN,BLUE,SPEED,0,REPEAT] )

def setFade():    
    writeValue( [2,LED,RED,GREEN,BLUE,SPEED,0] )

def setColor():
    writeValue( [1,LED,RED,GREEN,BLUE,0,0] )


set_luxafor("red")

@app.route('/webhook', methods=['POST'])
def webhook():
    if request.method == 'POST':
        post_data = request.get_json()
        print("Data received from Webhook is: ", request.get_json()['color'])
        
        color = post_data['color']
        print(color)
        
        set_luxafor(color)

        return "OK", 200

app.run(host='0.0.0.0', port=8000, threaded=True)
