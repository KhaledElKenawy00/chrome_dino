int emgPin=A0;
int emgPin_1=A1;
int emgValue=0;
int emgValue_1=0;
const int fsrPin = A2;  // مستشعر الضغط متصل بالمدخل التناظري A0
int threshold = 500;    // العتبة التي عندها نقول إن العضلة تحركت

int fsrValue = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);

}

void loop() {
  // put your main code here, to run repeatedly:
  emgValue= analogRead(emgPin);
  emgValue_1= analogRead(emgPin_1);
  fsrValue = analogRead(fsrPin);  // قراءة قيمة المستشعر

    if(fsrValue > 500)
    {
      Serial.println("JUMP");
      while(fsrValue > 500)
      {
        fsrValue = analogRead(fsrPin);
      }
    }
    Serial.println("left= " +String(emgValue) + "         " +"right= "+ String(emgValue_1));

  
    

    delay(100);

}