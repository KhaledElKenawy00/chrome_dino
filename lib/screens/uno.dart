import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:serial_port_win32/serial_port_win32.dart';

class Uno extends StatefulWidget {
  const Uno({super.key});

  @override
  State<Uno> createState() => _UnoState();
}

class _UnoState extends State<Uno> {
  Timer? serialListener;
  SerialPort? arduinoPort;
  bool isListening = true;

  bool isArduinoConnectted() {
    // الحصول على المنافذ المتاحة
    final ports = SerialPort.getAvailablePorts();
    if (ports.isEmpty) {
      print("⚠️ لا توجد منافذ متاحة.");
      return false;
    }

    // البحث عن منفذ Arduino عبر معرفات الأجهزة
    final List<PortInfo> portInfoList = SerialPort.getPortsWithFullMessages();
    SerialPort? arduinoPort;

    for (var portInfo in portInfoList) {
      print("🔍 فحص المنفذ: ${portInfo.portName}");
      if (portInfo.hardwareID.toLowerCase().contains("usb") ||
          portInfo.friendlyName.toLowerCase().contains("arduino")) {
        print("✅ تم العثور على Arduino في: ${portInfo.portName}");
        arduinoPort = SerialPort(
          portInfo.portName,
          openNow: true,
          BaudRate: 9600,
        );
      }
    }

    if (arduinoPort == null) {
      print("❌ لم يتم العثور على جهاز Arduino متصل.");
      return false;
    } else {
      print("✅ تم الاتصال بنجاح.");
      return true;
    }
  }

  SerialPort checkArduinoConnecttedPortName() {
    // الحصول على المنافذ المتاحة
    final ports = SerialPort.getAvailablePorts();
    if (ports.isEmpty) {
      print("⚠️ لا توجد منافذ متاحة.");
    }

    // البحث عن منفذ Arduino عبر معرفات الأجهزة
    final List<PortInfo> portInfoList = SerialPort.getPortsWithFullMessages();

    try {
      for (var portInfo in portInfoList) {
        print("🔍 فحص المنفذ: ${portInfo.portName}");
        if (portInfo.hardwareID.toLowerCase().contains("usb") ||
            portInfo.friendlyName.toLowerCase().contains("arduino")) {
          print("✅ تم العثور على Arduino في: ${portInfo.portName}");
          arduinoPort = SerialPort(portInfo.portName, BaudRate: 9600);
        }
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains("Win32 Error Code is 5") ||
          errorMessage.contains("Win32 Error Code is 6") ||
          errorMessage.contains("Win32 Error Code is 7") ||
          errorMessage.contains("Win32 Error Code is 8") ||
          errorMessage.contains("Win32 Error Code is 3") ||
          errorMessage.contains("Win32 Error Code is 4") ||
          errorMessage.contains("Win32 Error Code is 1") ||
          errorMessage.contains("Win32 Error Code is 2") ||
          errorMessage.contains("Win32 Error Code is 9") ||
          errorMessage.contains("Win32 Error Code is 10") ||
          errorMessage.contains("Win32 Error Code is 0") ||
          errorMessage.contains("ClearCommError")) {
        print("⚠️ تم فصل جهاز Arduino. إيقاف الاستماع...");
        stopListening();
      }
    }
    listenToArduino(arduinoPort!);
    return arduinoPort!;
  }

  void stopListening() {
    try {
      serialListener?.cancel();
      if (arduinoPort != null && arduinoPort!.isOpened) {
        arduinoPort!.close();
      }
      isListening = false;
      print("🛑 Stopped listening to Arduino.");
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains("Win32 Error Code is 5") ||
          errorMessage.contains("Win32 Error Code is 6") ||
          errorMessage.contains("Win32 Error Code is 7") ||
          errorMessage.contains("Win32 Error Code is 8") ||
          errorMessage.contains("Win32 Error Code is 3") ||
          errorMessage.contains("Win32 Error Code is 4") ||
          errorMessage.contains("Win32 Error Code is 1") ||
          errorMessage.contains("Win32 Error Code is 2") ||
          errorMessage.contains("Win32 Error Code is 9") ||
          errorMessage.contains("Win32 Error Code is 10") ||
          errorMessage.contains("ClearCommError")) {
        print("⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️v");
        stopListening();
      }
    }
  }

  void listenToArduino(SerialPort port) async {
    if (!port.isOpened) {
      print("❌ المنفذ غير مفتوح. فتح الاتصال...");
      try {
        port.open();
      } catch (e) {
        print("❌ فشل فتح المنفذ: $e");
        return;
      }
    }

    print("🔄 بدء الاستماع إلى Arduino...");

    serialListener = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      while (port.isOpened) {
        try {
          final data = await port.readBytes(
            1024,
            timeout: Duration(milliseconds: 500),
          );

          if (data.isNotEmpty) {
            String message = utf8.decode(data).trim();

            print("📡 البيانات المستلمة: $message");

            if (message.contains("JUMP")) {
              print("⬆️ تنفيذ القفز!");
            }
          }
        } catch (e) {
          print("❌ خطأ أثناء القراءة: $e");
        }
      }

      print("🔴 توقف الاستماع. المنفذ مغلق.");
    });
  }

  @override
  void initState() {
    super.initState();
    checkArduinoConnecttedPortName();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("UNO")),
      body: Center(
        child: InkWell(
          onTap: () => checkArduinoConnecttedPortName(),
          child: Text("UNO "),
        ),
      ),
    );
  }
}
