const int fsrPin = A0;  // مستشعر الضغط متصل بالمدخل التناظري A0
int threshold = 500;    // العتبة التي عندها نقول إن العضلة تحركت

void setup() {
    Serial.begin(9600);
    Serial.println("FSR Sensor Ready");
}

void loop() {
    int fsrValue = analogRead(fsrPin);  // قراءة قيمة المستشعر
   

     if (fsrValue > threshold) {
        Serial.println("JUMP");  // إرسال إشارة القفز
    }


}
