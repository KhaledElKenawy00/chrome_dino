const int buttonPin = 2; // Pin where the button is connected
int buttonState = HIGH;  // Variable to store the current button state

void setup() {
  Serial.begin(9600); // Initialize serial communication at 9600 baud rate
  pinMode(buttonPin, INPUT_PULLUP); // Set the button pin as input with internal pull-up resistor
}

void loop() {
  int newState = digitalRead(buttonPin); // Read the current state of the button

  if (newState != buttonState) { // Detect state change (button pressed or released)
    buttonState = newState; // Update the button state

    if (buttonState == LOW) { // Button is pressed (LOW because of INPUT_PULLUP)
      Serial.println("PRESSED"); // Send "PRESSED" to the serial monitor
    }
    // No action when the button is released
  }

  delay(50); // Small delay to debounce the button
}