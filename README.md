 
      ==================================
      DIY MODEL ROCKET LOGGING ALTIMETER
      ==================================
      
      This Arduino based device logs the altitude of model rocket flights (e.g. water rockets) with a barometric pressure sensor 
      and displays the data on a computer via a Processing Sketch. The device logs data with a sample rate of 20Hz. 
      The Processing Sketch processes the data and displays the flight path as a curve. 
      The Sketch also calculates and displays maximum speed and maximum altitude of the flight path.
      
      
     
      ==========
      MATERIALS:
      ==========
      
      - Arduino Nano
      - BMP085 (/BMP180) Barometric sensor breakout board 
      - Push button
      - Power switch
      - 2* 2K Resistors
      - 3* Button Cells CR2032
      
      
      
      ===============
      HARDWARE SETUP:
      ===============
      
      Power:            3* 3V button Cells in parallel to Vin with switch in power line
      Voltage readout:  2K-2K voltage divider between +Vbat and GND connected to A6
      Sensor:           Barometric sensor breakout board connected via I²C
      User Interface:   Push-button to be connected between pin 2 and GND
      
      
      
      ===========
      HOW TO USE:
      ===========
      
      Turn the device on with the power switch. 
      The red LED (Pin13) turns on. 
      Push the button to arm the device and to set 0m reference altitude.
      The red led blinks slowly.
      The device now logs permanently data in a ringbuffer and waits for apogee.
      Once apogee was detected, the device blinks very fast for another 15 seconds (it is logging another 300 data points).
      After that the LED shows the following blinking pattern:
      Blink fast - LED off - blink fast - LED off - [repeat]
      The device has now stored 500 data points (200 before apogee and 300 after) in its EEPROM and can be turned off via 
      the power switch.
      
      Connect the turned-off device to the PC via USB.
      Run the processing Sketch (you might have to change the port address in the Sketch to the Arduino Port).
      The device transmits now the data from the EEPROM to the processing sketch.
      
      The Processing Sketch displays the data: 
      The grey bars in the background represent one second. 
      The red horizontal lines represent 10m height. The Sketch displays the maximum altitude (apogee)
      and calculates the maximum speed in km/h.
      The Sketch also displays the battery voltage (because the three button cells won't last forever).
      The Sketch saves a screenshot of the visualisation and the processed data as .CSV file in the Sketch's /data folder.
   
