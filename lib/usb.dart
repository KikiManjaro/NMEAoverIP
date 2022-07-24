import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:libserialport/libserialport.dart';
import 'package:usb_serial/usb_serial.dart';

class Serial {
  static const platform = MethodChannel('flutter.native/helper');

  Future<String> changeColor(String color) async {
    try {
      final String result = await platform.invokeMethod("changeColor", {"color": color});
      print('RESULT -> $result');
      color = result;
    } on PlatformException catch (e) {
      print(e);
    }
    return color;
  }

}
