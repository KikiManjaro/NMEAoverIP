//
// Generated file. Do not edit.
//

// ignore_for_file: directives_ordering
// ignore_for_file: lines_longer_than_80_chars

import 'package:geolocator_web/geolocator_web.dart';
import 'package:network_info_plus_web/network_info_plus_web.dart';
import 'package:toast/toast_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(Registrar registrar) {
  GeolocatorPlugin.registerWith(registrar);
  NetworkInfoPlusPlugin.registerWith(registrar);
  ToastWebPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}