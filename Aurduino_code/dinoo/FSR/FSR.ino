const int fsrPin = A0;  // مستشعر الضغط متصل بالمدخل التناظري A0

void setup() {
    Serial.begin(115200);
    Serial.println("FSR Sensor Ready");
}

void loop() {
    int fsrValue = analogRead(fsrPin);  // قراءة قيمة المستشعر
    Serial.println(fsrValue);  // إرسال القيمة إلى الكمبيوتر عبر Serial
    delay(100);
}
