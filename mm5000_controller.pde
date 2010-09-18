#include <WString.h>
#include <Firmata.h>

///////////////////////////////////////////////////////////////////////////////
//                  Mary Mack 5000 Arduino Code                              //
//                          Kaho Abe                                         //           
//                        July 6, 2010                                       //
///////////////////////////////////////////////////////////////////////////////
//References:                                                                //
//http://www.arduino.cc/                                                     //
//http://itp.nyu.edu/physcomp/Tutorials/Multiplexer                          //
//http://www.kasperkamperman.com/blog/arduino/arduino-flash-communication/   //
///////////////////////////////////////////////////////////////////////////////

/// the address pins will go in order from the first one:
const int first4067Pin = 2;
const int firstSwitchPin = 10;
const int firstAnalogPin = 1;

String inString;

/////////////////////////////SETTING UP//////////////////////////////
void setup() {

  //Set up for Firmata connection
  Serial.begin(57600);
  Firmata.setFirmwareVersion(2, 1);
  Firmata.begin(57600);
  
  // set up for 4067 MULTIPLEXER pins on Arduino
  for (int pinNumber = first4067Pin; pinNumber < first4067Pin + 4; pinNumber++) { 
    pinMode(pinNumber, OUTPUT);
    digitalWrite(pinNumber, LOW);
  }

  // set up for MAX4544 IC SWITCH pins on Arduino
  for (int pinNumber = firstSwitchPin; pinNumber < firstSwitchPin + 4; pinNumber++) {
    pinMode(pinNumber, OUTPUT);
    digitalWrite(pinNumber, HIGH);
  }
}

////////////////////////////////MAIN PART/////////////////////////////
void loop() {
  inString="";//make sure inString string is empty at beginning of cycle
  
  //Each glove takes a turn reading and then adds to the string each time
  for (int pinNumber = firstSwitchPin; pinNumber < firstSwitchPin + 4; pinNumber++) {  
    digitalWrite(pinNumber, LOW);
    int addToString = filter(analogRead(pinNumber-9)); //kind of a dumb way to establish pin number for the analog in pin
    inString.append(addToString);
    resetPins(); //resets all pins so that none are being read to prepare for next cycle
  }
 
  // loop over all the input channels, read and add to string for each
  for (int thisChannel = 0; thisChannel < 12; thisChannel++) {
    setChannel(thisChannel);
    int analogReading = filter(analogRead(0));  
    inString.append(analogReading);
  } 
   
  //if any combo string matches with any of the possible combos then...
  //this is an important step to clean up the data that gets sent
  if(inString.equals("4321000000000000") || 
     inString.equals("2143000000000000") ||  
     inString.equals("0000000012340000") ||    
     inString.equals("0000214300000000") ||  
     inString.equals("3010000000000000") ||  
     inString.equals("0402000000000000") ||   
     inString.equals("0000000000005600") ) {
      //send the string to the computer (flash)
     Firmata.sendString(inString);
   }
}


/////////////////////////////FUNCTIONS//////////////////////////////

// this method sets the address pins to pick which input channel
// is connected to the multiplexer's output:
void setChannel(int whichChannel) {
  // loop over all four bits in the channel number:
  for (int bitPosition = 0; bitPosition < 4; bitPosition++) {
    // read a bit in the channel number:
    int bitValue = bitRead(whichChannel, bitPosition);  
    // pick the appropriate address pin:
    int pinNumber = bitPosition + first4067Pin;
    // set the address pin
    // with the bit value you read:
    digitalWrite(pinNumber, bitValue);
  }
}

//this function makes sure that the MAX4544 IC SWITCH pins are all reset
void resetPins(){
  for (int pinNumber = firstSwitchPin; pinNumber < firstSwitchPin + 4; pinNumber++) {
    digitalWrite(pinNumber, HIGH);  
  }
}

//this function is the filter than converts the 0 to 1023 to the assigned combo number which gets used in the string
// CL: One of the back of hand, Unqiue Voltage ID between 150 - 250, combo number 5
// AL: Player 1 left hand, Unique Voltage ID between 300-400, combo number 2
// BL: Player 2 left hand, Unique Voltage ID between 450-550, combo number 4
// CR: The other back of hand, Unique Voltage ID between 600-700, combo number 6
// BR: Player 2 right hand, Unique Voltage ID between 750-850, combo number 3
// AR: Player 1 right hand, Unique Voltage ID between 900-1023, combo number 1
int filter(int number) {
  if (number >= 150 && number < 250) {// CL 5
       return   5;
  }
  if (number >= 300   && number < 400  ) {// AL 2 
       return   2;
  }
  if (number >= 450   && number < 550  ) {// BL 4
       return   4;
  }
  if (number >= 600   && number < 700  ) {// CR 6
       return   6;
  }
  if (number >= 750   && number < 850  ) {// BR 3 
       return   3;
  }
  if (number >= 900) {//  AR 1 
       return   1;
  }
  else {
       return   0;
  }
}


