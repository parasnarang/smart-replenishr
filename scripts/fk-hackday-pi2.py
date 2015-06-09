import requests
import RPi.GPIO as GPIO
import time
import json
GPIO.setmode(GPIO.BCM)
 
TRIG = 23
ECHO = 24
PRESSURE = 22
BUTTON = 17
prev_button_input = 1
threshold_set = 0

GPIO.setup(TRIG,GPIO.OUT)
GPIO.setup(ECHO,GPIO.IN)
GPIO.setup(PRESSURE,GPIO.IN)
GPIO.setup(BUTTON,GPIO.IN)

GPIO.output(TRIG, False)
print "Waiting For Sensor To Settle"
time.sleep(2)

hostname = 'http://192.168.43.174:3000'
pressureSensor = 'PressureSensor'
sonarSensor = 'SonarSensor'
headers = {'Content-Type': 'application/json'}

def add_sonar_sensor():
    print "--- Adding Sonar Sensor ---"
    url = hostname + '/devices/add'
    payload = {'name':sonarSensor}
    response = requests.post(url, headers=headers, data=json.dumps(payload))
    if response.status_code==200:
        print "--- Sonar Sensor Added ---"

def add_pressure_sensor():
    print "--- Adding Pressure Sensor ---"
    url = hostname + '/devices/add'
    payload = {'name':pressureSensor}
    response = requests.post(url, headers=headers, data=json.dumps(payload))
    if response.status_code==200:
        print "--- Pressure Sensor Added ---"

def set_sonar_threshold(value):
    url = hostname + '/devices/threshold'
    print "--- Setting Threshold ---" + url
    payload = {'name':sonarSensor,'value':value}
    response = requests.post(url, headers=headers, data=json.dumps(payload))
    if response.status_code==200:
        print "--- Threshold Set Successfully ---"

def trigger_sonar_sensor(value):
    print "--- Initializing Sonar Breach Check ---"
    url = hostname + '/devices/trigger/sonar'
    payload = {'name':sonarSensor,'value':value}
    response = requests.post(url, headers=headers, data=json.dumps(payload))
    if response.status_code==200:
        print "--- Validation Check Done ---"

def trigger_pressure_sensor(value):
    print "--- Triggering Pressure Sensor Breach ---"
    url = hostname + '/devices/trigger/pressure'
    payload = {'name':pressureSensor,'value':value}
    response = requests.post(url, headers=headers, data=json.dumps(payload))
    if response.status_code==200:
        print "--- Pressure Set Successfully ---"

def skipper(val):
    skipper_i = 0
    print "skip", val
    while skipper_i < val:
        skipper_i = (skipper_i+1) % val
        time.sleep(0.001)

while True:
    time.sleep(2)
    GPIO.output(TRIG, True)
    time.sleep(0.00001)
    GPIO.output(TRIG, False)
    while GPIO.input(ECHO)==0:
        pulse_start = time.time()
    while GPIO.input(ECHO)==1:
        pulse_end = time.time()
    pulse_duration = pulse_end - pulse_start
    distance = pulse_duration * 17150
    distance = round(distance, 2)
    print "Distance:",distance,"cm"

    if(threshold_set==1):
        trigger_sonar_sensor(distance)
    
    button_input = GPIO.input(BUTTON)
    if((not prev_button_input) and button_input==1):
        print "Button Pressed"
        set_sonar_threshold(distance)
        threshold_set = 1
    prev_button_input = button_input

    if(GPIO.input(PRESSURE)==1):
        trigger_pressure_sensor(True)
    else:
        trigger_pressure_sensor(False)


