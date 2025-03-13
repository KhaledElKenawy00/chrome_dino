# R F I Game with Arduino EMG Sensor & FSR Sensor

This Flutter project is a game similar to the Chrome Dino game, but controlled using an Arduino EMG sensor. The game detects muscle movement and triggers a jump when the sensor sends a "JUMP" signal.

## Features
- Real-time connection with Arduino using `serial_port_win32`
- Detects muscle movement via an EMG sensor and sends jump signals
- Simple physics with gravity and velocity
- Randomized cactus obstacles
- Score tracking
- Game over detection

## Requirements
- **Flutter** (latest stable version)
- **Dart** (latest stable version)
- **serial_port_win32** package (v2.1.12)
- **Arduino Board** (e.g., Arduino Uno)
- **EMG Sensor**

## Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/dino-arduino-game.git
   cd dino-arduino-game
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Connect your Arduino and upload the necessary sketch (example below).
4. Run the app:
   ```sh
   flutter run
   ```

## Arduino Code Example
Upload this code to your Arduino to send a "JUMP" signal when muscle movement is detected:
```cpp
const int sensorPin = A0;
const int threshold = 500;

void setup() {
  Serial.begin(9600);
}

void loop() {
  int sensorValue = analogRead(sensorPin);
  if (sensorValue > threshold) {
    Serial.println("JUMP");
    delay(500);
  }
}
```

## How It Works
1. The app checks for available serial ports and connects to the Arduino.
2. It listens for serial messages from the Arduino.
3. When "JUMP" is received, the dino character jumps.
4. The game runs continuously with obstacles appearing at random intervals.
5. If the dino collides with a cactus, the game ends, and a restart option appears.

## Troubleshooting
- **Arduino not detected?** Check that the correct port is used in `SerialPort.getAvailablePorts()`.
- **Jump not triggering?** Verify that the EMG sensor is properly connected and the threshold is correctly set.
- **Game lagging?** Try running the app in release mode with `flutter run --release`.

## Future Improvements
- Add sound effects for jumps and collisions.
- Implement multiple difficulty levels.
- Improve UI with animations and effects.

## License
This project is open-source. Feel free to modify and enhance it as needed.

---
### Author: Khaled Mostafa Esmail
For questions or contributions, feel free to open an issue or submit a pull request!

