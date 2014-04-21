
 // For normal motor use
 #define FORWARD HIGH
 #define REVERSE LOW
 
 // For normal claw use
 #define GRAB 1
 #define RELEASE -1
 #define STOP 0
 #define HOLD 20
 #define CLOSE 127
 #define OPEN -127
 #define ACTION_TIME 200
 
  int pinI1=8;//define I1 interface
  int pinI2=11;//define I2 interface 
  int speedpinA=9;//enable motor A
  int pinI3=12;//define I3 interface 
  int pinI4=13;//define I4 interface 
  int speedpinB=10;//enable motor B
  int motorSpeed = 127;  
  
  int motorArray[4] = {2,3,4,5};  
  int sensorArray[4] = {A0,A1,A2,A3};
  int stopDirection[4] = {FORWARD,FORWARD,FORWARD,FORWARD};

  void stop()//
  {
     digitalWrite(pinI1,LOW);
     digitalWrite(pinI2,LOW);
     delay(10);
     for(int x = 0 ; x < 4; x++) {
       digitalWrite(motorArray[x],LOW);
     }

  }

  
  void waitMS(long time_delay,int motorNumber, int DIRECTION) {
    long startTime = millis();
    while(millis() - startTime < time_delay){
      if(digitalRead(sensorArray[motorNumber]) == 1 && DIRECTION==stopDirection[motorNumber]) {
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
      analogWrite(speedpinA, motorSpeed);
      digitalWrite(pinI1,DIRECTION);
      digitalWrite(pinI2,HIGH - DIRECTION);
      waitMS(time_delay,motor,DIRECTION);
      stop();
      
  }

  
  int clawPosition = STOP;
  void setClaw(int GRABPOSITION) {
      // Set the claw piece
      if(GRABPOSITION == GRAB && clawPosition != GRAB) {
        clawPosition = GRAB;
        analogWrite(speedpinB, CLOSE);
        digitalWrite(pinI3,HIGH);
        digitalWrite(pinI4,LOW);
        delay(ACTION_TIME);
        analogWrite(speedpinB,HOLD);
        
      } else if(GRABPOSITION == RELEASE && clawPosition != RELEASE) {
        clawPosition = RELEASE;
        analogWrite(speedpinB,OPEN);
        digitalWrite(pinI3,LOW);
        digitalWrite(pinI4,HIGH);
        delay(ACTION_TIME);
        analogWrite(speedpinB,STOP);
      } 
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
    
    Serial.begin(9600);
  }

  // Commands are 4 bytes,
  //                 uint8 int8              uint8  uint8 (uint16)
  // They consist of Motor,Spd/Direction,and TimeL, TimeH
  unsigned char command[4];
  char comCount = 0;
  int motorNum = -1;
  int direct;
  long time = 0;
  
  void loop() {
    if(Serial.available() > 0) {
      command[comCount++]  = Serial.read();
      if(comCount == 4) {
        comCount = 0;
        if(command[0] == 10) {
          // Claw action
          if(command[1] == 1) {
            Serial.println("Claw Grabbing!");
            setClaw(GRAB);
          }
          else if(command[1] == 2){
            Serial.println("Claw Released!");
            setClaw(RELEASE);
          }
          else Serial.println("Invalid Command!");
          Serial.println(" --- Command Executed! --- ");
        } else {
          // Motor Movement
          if(command[1] != 0) {
            motorSpeed = (int)command[1]&0x7F;
            long timeDelay = (long)((((unsigned long)command[3]) << 8) | (unsigned long)command[2]);
            
            Serial.print("M: ");
            Serial.print((int)command[0]);
            Serial.print(" D: ");
            Serial.print((command[1] & 0x80) ? REVERSE : FORWARD);
            Serial.print(" Time: ");
            Serial.print((int)timeDelay);
            Serial.println(" Command Recieved!");
            
            setMotor((int)command[0],(command[1] & 0x80) ? REVERSE : FORWARD, timeDelay);
            Serial.println(" --- Command Executed! --- ");
          }          
        }
      }
    }
  }

