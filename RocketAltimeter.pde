/*//////////////////////////////////////////////////////////////////////////////////////////////
 Water rocket recording altimeter readout & visualization 
 reads values from Arduino Nano via serial port and displays them
 
 Published under the Beer Ware License by Niklas Roy (www.niklasroy.com)
 //////////////////////////////////////////////////////////////////////////////////////////////*/


import processing.serial.*;

Serial myPort;          // Create object from Serial class
int pVal, val;          // Data received from the serial port
float[] altitude = new float[501]; // saves altitudes in meters
int   count=0;          // index count of serial retreived byte
int   measurementIndex; // index count of whole curve measurement 
float batteryVoltage;   // voltage of batterypack 
float maxHeight=-20;    // maximum height
int   maxHeightIndex=0; // position of maximum height 
float maxSpeed=-20;     // maximum speed in km/h
int   maxSpeedIndex=0;  // position of maximum speed
PFont font;

void setup() 
{
  size(1600, 900);
  String portName = Serial.list()[5];
  myPort = new Serial(this, portName, 9600);

  font = createFont("FuturaBT-Heavy-32.vlw", 32);
  textFont(font);

  stroke(255);
}

void draw()
{
  if ( myPort.available() > 0) {  // If data is available,
    val = myPort.read();          // read it and store it in val
    print(val);

    if (count==1) { // first real byte is the index of recordings
      measurementIndex=val;
    }

    if (count==2) { // second byte contains battery voltage info
      batteryVoltage=val;
      batteryVoltage=batteryVoltage*10/255;
    }

    if (count>3 && count<503) { // altimeter recording data
      altitude[count-4]=val;
      altitude[count-4]/=2;
      altitude[count-4]-=10;
      if (val==0) {
        altitude[count-4]=0;
      }
    }
    if (val==255) {
      println("----------");
      count=0;
    }

    print(".");
    print(count);
    print(", ");
    count++;
  }

  // low pass filter altitude values & find maximum height
  float[] filteredAltitude = new float[501];
  for (int i=3; i<498; i++) {
    filteredAltitude[i]=(altitude[i-2]+altitude[i-1]+altitude[i]+altitude[i+1]+altitude[i+2])/5;
    if (filteredAltitude[i]>maxHeight) {
      maxHeight=filteredAltitude[i];
      maxHeightIndex=i;
    }
  }

  // calculate speed
  float maxDelta=-1;
  for (int i=9; i<492; i++) { // find maximum difference between 10 altitude samples
    if (abs(filteredAltitude[i-5]-filteredAltitude[i+5])>maxDelta) {
      maxDelta=abs(filteredAltitude[i-5]-filteredAltitude[i+5]);
      maxSpeedIndex = i;
    }
  }
  maxSpeed=maxDelta/1000*3600*20/10; // calculate speed in km/h (1000m per km/h, 3600 seconds per hour, 20 samples / second, time between 10 samples)



  // draw on screen

  background(0);

  // draw seconds grid
  fill(16);
  noStroke();
  for (int s=0; s<550; s+=40) {
    rect(s*3, 0, 60, height);
  }

  // draw meter grid
  strokeWeight(1);
  for (int m=0; m<120; m+=5) {
    if (m%10==0) {
      stroke(128, 64, 32);
    } else {
      stroke(64);
    }
    line(10, 820-m*8, 1590, 820-m*8);
  }



  // draw curve
  stroke(255);
  strokeWeight(3); 
  for (int i=3; i<498 && i<count-10; i++) {
    line(i*3+40, 820-filteredAltitude[i-1]*8, i*3+43, 820-filteredAltitude[i]*8);
  }

  // draw text block
  int xText=40;
  int yText=70;
  int yLineSpace=40;

  fill(255);  
  text("Measurement #: ", xText, yText);
  text(measurementIndex, xText+290, yText);
  yText+=yLineSpace;

  if (batteryVoltage<6.3) {
    int t=millis();
    t=t/500;
    if (t%2==0) {
      fill(255, 128, 64);
    } else {
      fill(255);
    }
  }
  text("Battery (V): ", xText, yText);
  text(nf(batteryVoltage, 1, 1), xText+290, yText);
  yText+=yLineSpace;

  // draw speed 
  stroke(64, 128, 255);
  line(maxSpeedIndex*3+40, yText+10, maxSpeedIndex*3+40, 810-filteredAltitude[maxSpeedIndex]*8);
  fill(64, 128, 255);
  text("Maximum speed: ", xText, yText);
  int digits=1;
  if (maxSpeed>=10) {
    digits++;
  }
  if (maxSpeed>=100) {
    digits++;
  }
  text(nf(maxSpeed, digits, 1), constrain(maxSpeedIndex, 100, 1000)*3+38, yText);
  text("km/h", constrain(maxSpeedIndex, 100, 1000)*3+75+digits*18, yText);
  yText+=yLineSpace;

  // draw altitude
  stroke(255, 128, 64);
  line(maxHeightIndex*3+40, yText+10, maxHeightIndex*3+40, 810-filteredAltitude[maxHeightIndex]*8);
  fill(255, 128, 64);
  text("Maximum altitude: ", xText, yText);
  digits=1;
  if (maxHeight>=10) {
    digits++;
  }
  if (maxHeight>=100) {
    digits++;
  }
  text(nf(maxHeight, digits, 2), constrain(maxHeightIndex, 100, 1000)*3+38, yText);
  text("m", constrain(maxHeightIndex, 100, 1000)*3+90+digits*18, yText);
  yText+=yLineSpace;

  if (count==503) { // save data to harddisk
    println();
    println();
    save("RocketData"+measurementIndex+".png");
    println("Image saved as 'RocketData"+measurementIndex+".png'");

    PrintWriter output;
    output = createWriter("RocketData"+measurementIndex+".csv");
    output.println("Rocket Data Measurement Number "+measurementIndex);
    output.println("Samples are Altitude in Meters - Sample Rate is 20Hz (20 Samples / Second)");
    output.println();
    for (int i=3; i<497; i++) {
      output.print(filteredAltitude[i]); // write altitude data to the file as comma seperated value
      output.println(",");
    }
    output.println("");
    output.println("Maximum Speed: "+maxSpeed+" km/h");
    output.println("Maximum Height: "+maxHeight+" m");
    output.flush(); // Writes the remaining data to the file
    output.close(); // Finishes the file
    println("Data saved as 'RocketData"+measurementIndex+".csv'");
    count++;
  }
}
