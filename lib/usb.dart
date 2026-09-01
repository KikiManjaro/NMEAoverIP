
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Serial {
  static const platform = MethodChannel('flutter.native/helper');

  Future<String> changeColor(String color) async {
    try {
      final String result = await platform.invokeMethod("changeColor", {"color": color});
      debugPrint('RESULT -> $result');
      color = result;
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
    return color;
  }

}
