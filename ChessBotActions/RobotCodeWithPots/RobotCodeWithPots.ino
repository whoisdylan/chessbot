
 // For normal motor use
 #define FORWARD HIGH
 #define REVERSE LOW
 
 // For normal claw use
 #define GRAB 1
 #define RELEASE -1
 #define STOP 0
 #define HOLD 0
 #define CLOSE 127
 #define OPEN -127
 #define ACTION_TIME 800
 #define CLOSE_ADDITION 250 
  int pinI1=8;//define I1 interface
  int pinI2=11;//define I2 interface 
  int speedpinA=9;//enable motor A
  int pinI3=12;//define I3 interface 
  int pinI4=13;//define I4 interface 
  int speedpinB=10;//enable motor B
  int motorSpeed = 127;  
  
  int motorArray[4] = {2,3,4,5};  
  int sensorArray[4] = {A0,A1,A2,A3};
  int stopDirection[4] = {REVERSE,REVERSE,FORWARD,REVERSE};

  int increasingDirection[4] = {REVERSE,FORWARD,FORWARD,REVERSE};
  //int upperBound[4] = {740,765,745,723};
  //int lowerBound[4] = {285,725,680,683};
  int upperBound[4] = {742,850,1000,1000};
  int lowerBound[4] = {0,0,0,0};

  #define avVal 7
  int averageValues[4][avVal];
  void initArray() {
    for(int x =0; x < 4; x ++) {
      for(int y = 0; y < avVal; y++) {
        averageValues[x][y] =0;
      }
    }
  }

  
  void captureValues( int index){
       for(int y = avVal; y > 0; y--) {
          averageValues[index][y] = averageValues[index][y-1];
       }
       delay(19);
       analogRead(A5);
       delay(1);
       averageValues[index][0] = analogRead(sensorArray[index]);
    
  }
  
  int getValue(int index) {
    long ret = 0;
    captureValues(index);
    for( int y = 0; y < avVal; y++) {
       ret += averageValues[index][y];
    }
    return (int) (ret / avVal);
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
  #define CLOSE_ENOUGH 0
  #define SPEED_LOW 50
  #define SPEED_HIGH 175
  #define INTEGRAL_SIZE 10
  
  #define P 1.2
  #define I 1.0
  #define D 7.0
  void executeCommand(long time_delay,int motorNumber, int DIRECTION, int targetPosition) {
    long startTime = millis();
    captureValues(motorNumber);
    int sensorValue = getValue(motorNumber);
    int integral[INTEGRAL_SIZE] ;
    int last_error;
    // if less than target and increasing, continue
    // if its greater than and decreasing, continue
    // if the time hasn't been hit yet, continue

    int error = targetPosition - sensorValue;
            // take ABS of error
    for( int x = 0; x<INTEGRAL_SIZE; x ++)
      integral[x] = 0;
    error = error < 0 ? -error : error;
    last_error = error;
    while(millis() - startTime < time_delay && (error > CLOSE_ENOUGH || last_error >CLOSE_ENOUGH)) {
         //((targetPosition > sensorValue + CLOSE_ENOUGH && DIRECTION == increasingDirection[motorNumber]) ||
         //  (targetPosition < sensorValue - CLOSE_ENOUGH && DIRECTION != increasingDirection[motorNumber]))) {
     
      // Here is the P__ control loop.
      int DIRECTION = getValue(motorNumber) < targetPosition ?
                      increasingDirection[motorNumber] : 1 - increasingDirection[motorNumber];


      int derivative;
      error = targetPosition - sensorValue;
            // take ABS of error
      int integralSum = 0;
      for (int x = INTEGRAL_SIZE-1; x > 0 ; x --) {
        integral[x] = integral[x-1];
        integralSum = integralSum + integral[x];
      }
     
      integralSum = integralSum + error;
      integralSum = integralSum > 0 ? integralSum : -integralSum;
      integral[0] = error;

      error = error < 0 ? -error : error;
      derivative = error - last_error;

      // Slow down and stop if you approach the target value.
      motorSpeed = error*P;
      motorSpeed += integralSum*I;
      motorSpeed += derivative*D;
      if(motorSpeed > SPEED_HIGH)
        motorSpeed = SPEED_HIGH;
      analogWrite(speedpinA, motorSpeed);

      digitalWrite(pinI1,DIRECTION);
      digitalWrite(pinI2,HIGH - DIRECTION);

      
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
      last_error = error;
    }
  }
    
  #define TIMEOUT 5000
  void setMotor(int motor, int targetPosition, long timeout) {
      stop();
      getValue(motor);
      delay(100);
      for(int x = 0; x < avVal; x ++) {
        getValue(motor);
      }
      for(int x = 0 ; x < 4; x++) {
        digitalWrite(motorArray[x],(x == motor ? HIGH : LOW));
      }
      delay(10);
      
      
      // If target is greater than the current value, then move in the increasing direction
      // Otherwise move in the opposite direction
      timeout = timeout == 0 ? TIMEOUT : timeout;
      int DIRECTION = getValue(motor) < targetPosition ?
                                 increasingDirection[motor] : 1 - increasingDirection[motor];
      
      analogWrite(speedpinA, SPEED_LOW);
      digitalWrite(pinI1,DIRECTION);
      digitalWrite(pinI2,HIGH - DIRECTION);
      executeCommand(timeout,motor,DIRECTION,targetPosition);
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
        delay(ACTION_TIME + CLOSE_ADDITION);
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

    Serial.begin(9600);
    initArray();
  }

  // Commands are 5 bytes,
  //                 uint8  uint8    uint8    uint8     uint8
  // They consist of Motor, TargetL, TargetH, TimeoutL, TimeoutH
  unsigned char command[5];
  char comCount = 0;
  int motorNum = -1;
  long time = 0;
  
  void loop() {
//    captureValues();
//    delay(1);
    if(Serial.available() > 0) {
      command[comCount++]  = Serial.read();
      
      if(comCount == 5) {
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
          int targetDir = (int)((((unsigned long)command[2]) << 8) | (unsigned long)command[1]);
          long timeout = (int)((((unsigned long)command[4]) << 8) | (unsigned long)command[3]);
          Serial.print("Motor: ");
          Serial.print((int)command[0]);
          Serial.print(" Target: ");
          Serial.print(targetDir);
          Serial.print(" Timeout: ");
          Serial.print(timeout);
          Serial.print(" Current: ");
          Serial.println(getValue((int)command[0]));
          
          // For safety a timeout is added.
          setMotor((int)command[0],targetDir,timeout);
          Serial.print("Final: ");
          Serial.println(getValue((int)command[0]));
                    
        }
      }
    }
  }

