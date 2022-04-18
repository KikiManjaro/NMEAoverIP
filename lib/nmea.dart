import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nmea_to_network/ip.dart';

class NMEA {
  static NmeaMessage nmea = NmeaMessage("", DateTime(0));
  static Position pos = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime(0),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);

  static var nmeaList = ListQueue<NmeaMessage>();

  static State? locationState;
  static State? mapState;

  static Future<void> initNmeaReading() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      //TODO: add a popup to ask the user to enable location permissions
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Geolocator.getNmeaMessageStream().listen((nmea) {
      NMEA.nmea = nmea;
      nmeaList.addLast(nmea);
      if (nmeaList.length > 200) {
        nmeaList.removeFirst();
      }

      IP.sendUDPMessage(nmea.message);
      locationState?.setState(() {});
      mapState?.setState(() {});
    });

    Geolocator.getPositionStream().listen((pos) {
      NMEA.pos = pos;
    });
  }
}
