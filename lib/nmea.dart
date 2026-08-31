import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nmea_to_network/ip.dart';
import 'package:nmea_to_network/map.dart';

/// Simple NMEA message model.
///
/// The original code used `NmeaMessage` from `geolocator`, which was removed
/// in geolocator >=9.0. This local model keeps the app compiling on modern
/// Flutter / geolocator and lets us generate NMEA sentences from [Position].
class NmeaMessage {
  final String message;
  final DateTime timestamp;
  const NmeaMessage(this.message, this.timestamp);
}

class NMEA {
  static NmeaMessage nmea = NmeaMessage("", DateTime.fromMillisecondsSinceEpoch(0));
  static Position pos = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.fromMillisecondsSinceEpoch(0),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  static var nmeaList = ListQueue<NmeaMessage>();

  static State? locationState;
  static CustomMapState? mapState;

  /// Generate a minimal GGA + RMC sentence from a [Position].
  /// This replaces the removed `Geolocator.getNmeaMessageStream()` which
  /// only worked on Android with the legacy LocationManager.
  static String _positionToNmea(Position p) {
    // -- GGA sentence (fix data) --
    // Format: $GPGGA,hhmmss.ss,ddmm.mmmm,N,dddmm.mmmm,E,1,08,0.9,alt,M,0,M,,*cs
    final time = p.timestamp.toUtc();
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    final ss = time.second.toString().padLeft(2, '0');
    final timeStr = '$hh$mm$ss.00';

    String toNmeaLat(double lat) {
      final abs = lat.abs();
      final deg = abs.floor();
      final min = (abs - deg) * 60;
      return '${deg.toString().padLeft(2, '0')}${min.toStringAsFixed(4).padLeft(7, '0')}';
    }

    String toNmeaLon(double lon) {
      final abs = lon.abs();
      final deg = abs.floor();
      final min = (abs - deg) * 60;
      return '${deg.toString().padLeft(3, '0')}${min.toStringAsFixed(4).padLeft(7, '0')}';
    }

    final latStr = toNmeaLat(p.latitude);
    final latHem = p.latitude >= 0 ? 'N' : 'S';
    final lonStr = toNmeaLon(p.longitude);
    final lonHem = p.longitude >= 0 ? 'E' : 'W';
    final altStr = p.altitude.toStringAsFixed(1);

    String gga = 'GPGGA,$timeStr,$latStr,$latHem,$lonStr,$lonHem,1,08,0.9,$altStr,M,0,M,,';
    String rmc = 'GPRMC,$timeStr,A,$latStr,$latHem,$lonStr,$lonHem,${p.speed.toStringAsFixed(1)},${p.heading.toStringAsFixed(1)},${time.day.toString().padLeft(2, '0')}${time.month.toString().padLeft(2, '0')}${time.year.toString().substring(2)},,A';

    String checksum(String sentence) {
      int cs = 0;
      for (var c in sentence.codeUnits) {
        cs ^= c;
      }
      return cs.toRadixString(16).padLeft(2, '0').toUpperCase();
    }

    final ggaSentence = '\$${gga}*${checksum(gga)}';
    // We send GGA as primary; RMC could be added as second line if needed.
    // For backwards compat, return GGA.
    return ggaSentence;
  }

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
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Position stream — generates NMEA sentences on-the-fly.
    // This replaces the removed Geolocator.getNmeaMessageStream().
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    ).listen((pos) {
      final nmeaStr = _positionToNmea(pos);
      final msg = NmeaMessage(nmeaStr, pos.timestamp);

      NMEA.nmea = msg;
      nmeaList.addLast(msg);
      if (nmeaList.length > 200) {
        nmeaList.removeFirst();
      }

      IP.sendUDPMessage(msg.message);
      IP.sendMulticastMessage(msg.message);
      locationState?.setState(() {});
      mapState?.setState(() {});

      // Update cached position & map
      final isFirstFix = NMEA.pos.latitude == 0 && NMEA.pos.longitude == 0;
      NMEA.pos = pos;
      if (isFirstFix) {
        mapState?.gotoDefault();
      }
    });
  }
}
