
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
  int stopDirection[4] = {FORWARD,REVERSE,FORWARD,REVERSE};

  int increasingDirection[4] = {FORWARD,REVERSE,FORWARD,REVERSE};
  int upperBound[4] = {1000,1000,1000,1000};
  int lowerBound[4] = {100,100,100,100};

  #define avVal 10
  int averageValues[4][avVal];
  void initArray() {
    for(int x =0; x < 4; x ++) {
      for(int y = 0; y < avVal; y++) {
        averageValues[x][y] = analogRead(sensorArray[x]);
        delay(1);
      }
    }
  }

  
  void captureValues(){
    for(int x = 0; x < 4; x++) {
       for(int y = avVal; y > 0; y++) {
          averageValues[x][y] = averageValues[x][y-1];
       }
       averageValues[x][0] = analogRead(sensorArray[x]);
    } 
  }
  
  int getValue(int index) {
    int ret = 0;
    for( int y = 0; y < avVal; y++) {
       ret += averageValues[index][y];
    }
    return ret;
  }


  void stop()//
  {
     digitalWrite(pinI1,LOW);
     digitalWrite(pinI2,LOW);
     delay(10);
     for(int x = 0 ; x < 4; x++) {
       digitalWrite(motorArray[x],LOW);
     }

  }

 // To account for the noise margin
  #define CLOSE_ENOUGH 5
  #define SPEED_LOW 140
  #define SPEED_HIGH 255
  void executeCommand(long time_delay,int motorNumber, int DIRECTION, int targetPosition) {
    long startTime = millis();
    captureValues();
    int sensorValue = getValue(motorNumber);

    // if less than target and increasing, continue
    // if its greater than and decreasing, continue
    // if the time hasn't been hit yet, continue
    while(millis() - startTime < time_delay && 
         ((targetPosition > sensorValue + CLOSE_ENOUGH && DIRECTION == increasingDirection[motorNumber]) ||
           (targetPosition < sensorValue - CLOSE_ENOUGH && DIRECTION != increasingDirection[motorNumber]))) {
     
      // Here is the P__ control loop.
      int error = targetPosition - sensorValue;
      // take ABS of error
      error = error < 0 ? -error : error;
      // Slow down and stop if you approach the target value.
      motorSpeed = error > (SPEED_HIGH - SPEED_LOW) ? SPEED_HIGH : SPEED_LOW + error;
      analogWrite(speedpinA, motorSpeed);
      
      sensorValue = getValue(motorNumber);
      // If the value is greater than the upperBound and the direction is increasing, stop
      if(sensorValue > upperBound[motorNumber] && DIRECTION == increasingDirection[motorNumber]){
        stop();
        break;
      // If the value is less than the lowerBound and the direction is decreasing, stop
      } else if (sensorValue < lowerBound[motorNumber] && DIRECTION != increasingDirection[motorNumber]){
        stop();
        break;
      }
      
    }
  }
    
  #define TIMEOUT 5000
  void setMotor(int motor, int targetPosition) {
      stop();
      for(int x = 0 ; x < 4; x++) {
        digitalWrite(motorArray[x],(x == motor ? HIGH : LOW));
      }
      delay(10);
      
      // If target is greater than the current value, then move in the increasing direction
      // Otherwise move in the opposite direction
      int DIRECTION = getValue(motor) < targetPosition ?
                                 increasingDirection[motor] : 1 - increasingDirection[motor];
      
      analogWrite(speedpinA, SPEED_LOW);
      digitalWrite(pinI1,DIRECTION);
      digitalWrite(pinI2,HIGH - DIRECTION);
      executeCommand(TIMEOUT,motor,DIRECTION,targetPosition);
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
    initArray();
    Serial.begin(9600);
  }

  // Commands are 3 bytes,
  //                 uint8  uint8  uint8 (uint16)
  // They consist of Motor, TargetL, TargetH
  unsigned char command[3];
  char comCount = 0;
  int motorNum = -1;
  long time = 0;
  
  void loop() {
    captureValues();
    delay(1);
    if(Serial.available() > 0) {
      command[comCount++]  = Serial.read();
      if(comCount == 3) {
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
          char motorINTER = (char)command[1];
          motorINTER = motorINTER;
          if(motorINTER != 0) {
            int targetDir = (int)((((unsigned long)command[2]) << 8) | (unsigned long)command[1]);
            Serial.print("M: ");
            Serial.print((int)command[0]);
            Serial.print(" T: ");
            Serial.print(targetDir);
            Serial.println(" Command Recieved!");
            
            setMotor((int)command[0],targetDir);
            Serial.println(" --- Command Executed! --- ");
          }          
        }
      }
    }
  }

