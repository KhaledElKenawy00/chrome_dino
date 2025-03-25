  //FSR AURDUINO CODE
  const int fsrPin = A0;  // مستشعر الضغط متصل بالمدخل التناظري A0
  int threshold = 500;    // العتبة التي عندها نقول إن العضلة تحركت

  int fsrValue = 0;
  void setup() {
      Serial.begin(9600);
      //Serial.println("FSR Sensor Ready");
  }

  void loop() {
      fsrValue = analogRead(fsrPin);  // قراءة قيمة المستشعر
      if(fsrValue > 500)
      {
        Serial.println("JUMP");
        while(fsrValue > 500)
        {
          fsrValue = analogRead(fsrPin);
        }
      }

  }