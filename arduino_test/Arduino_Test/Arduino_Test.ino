
 #define FORWARD HIGH
 #define REVERSE LOW

  int pinI1=8;//define I1 interface
  int pinI2=11;//define I2 interface 
  int speedpinA=9;//enable motor A
  int pinI3=12;//define I3 interface 
  int pinI4=13;//define I4 interface 
  int speedpinB=10;//enable motor B
  int fwdspeed = 127;  
  
  int motorArray[4] = {2,3,4,5};  
  int sensorArray[4] = {A0,A1,A2,A3};
  int stopDirection[4] = {FORWARD,FORWARD,FORWARD,FORWARD};

  void stop()//
  {
     digitalWrite(pinI1,LOW);
     digitalWrite(pinI2,LOW);
     digitalWrite(pinI3,LOW);
     digitalWrite(pinI4,LOW);
     delay(10);
     for(int x = 0 ; x < 4; x++) {
       digitalWrite(motorArray[x],LOW);
     }

  }

  
  void waitMS(long time_delay,int motorNumber, int DIRECTION) {
    long startTime = millis();
    while(millis() - startTime < time_delay){
      if(  digitalRead(sensorArray[motorNumber]) ) {
        stop();
        break;
      }
    }
  }
    
    
  void setMotor(int motor, int DIRECTION, long time_delay) {
      stop();
      for(int x = 0 ; x < 4; x++) {
        digitalWrite(motorArray[x],(x == motor ? HIGH : LOW));
      }
      delay(10);
      analogWrite(speedpinA, fwdspeed);
      digitalWrite(pinI1,DIRECTION);
      digitalWrite(pinI2,HIGH - DIRECTION);
      waitMS(time_delay,motor,DIRECTION);
      stop();
      
  }
  


  void setup()
  {
    pinMode(motorArray[0], OUTPUT);      // sets the digital pin as output
    pinMode(motorArray[1], OUTPUT);      // sets the digital pin as output
    pinMode(motorArray[2], OUTPUT);      // sets the digital pin as output
    pinMode(motorArray[3], OUTPUT);      // sets the digital pin as output
    pinMode(pinI1,OUTPUT);
    pinMode(pinI2,OUTPUT);
    pinMode(speedpinA,OUTPUT);
    pinMode(pinI3,OUTPUT);
    pinMode(pinI4,OUTPUT);
    pinMode(speedpinB,OUTPUT);
    pinMode(sensorArray[0],INPUT);
    pinMode(sensorArray[0],INPUT);
    pinMode(sensorArray[0],INPUT);
    pinMode(sensorArray[0],INPUT);
    

  }

  // Commands are 4 bytes,
  //                 uint8 int8              uint8  uint8 (uint16)
  // They consist of Motor,Spd/Direction,and TimeL, TimeH
  char command[4];
  char comCount = 0;
  int motorNum = -1;
  int direct;
  long time = 0;
  
  void loop() {
    if(Serial.available()) {
      command[comCount++]  = Serial.read();
      if(comCount == 4) {
        comCount = 0;
        if(command[1] != 0) {
          fwdspeed = (int)command[1]&0x7F;
          setMotor((int)command[0],(command[1] & 0x80) ? REVERSE : FORWARD,
                   // TimeH << 8 | TimeL
                   (long)((((unsigned long)command[3]) << 8) | (unsigned long)command[2]));                 
          Serial.write(1);
        }          
      }
    }
  }

