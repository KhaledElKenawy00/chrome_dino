const int emgPin = A0;  // مستشعر العضلات متوصل على A0
int threshold = 800;    // العتبة التي عندها نقول إن العضلة تحركت

void setup() {
    Serial.begin(115200);  // تشغيل السيريال للتواصل مع الكمبيوتر
}

void loop() {
    int emgValue = analogRead(emgPin);  // قراءة البيانات من المستشعر
    Serial.println(emgValue);  // طباعة القيمة في السيريال
    
    if (emgValue > threshold) {
        Serial.println("JUMP");  // إرسال إشارة القفز
    }

    delay(50);  // تأخير بسيط لتقليل البيانات
}
