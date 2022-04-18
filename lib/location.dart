import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nmea_to_network/ip.dart';
import 'package:nmea_to_network/nmea.dart';

class Location extends StatefulWidget {
  const Location({Key? key}) : super(key: key);

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  _LocationState() {
    NMEA.locationState = this;
  }

  @override
  void dispose() {
    NMEA.locationState = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Position: ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              NMEA.pos.toString() +
                  "\naltitude: " +
                  NMEA.pos.altitude.toString() +
                  "\nheading: " +
                  NMEA.pos.heading.toString() +
                  "\nspeed: " +
                  NMEA.pos.speed.toString() +
                  "\naccuracy: " +
                  NMEA.pos.accuracy.toString() +
                  "\nspeedAccuracy: " +
                  NMEA.pos.speedAccuracy.toString(),
              style: TextStyle(fontSize: 18),
            ),
            const Text(
              'NMEA: ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            nmeaLogger(),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget nmeaLogger() {
    var nmeaLog = <Widget>[];
    for (var nmeaObj in NMEA.nmeaList) {
      nmeaLog.add(Text('${nmeaObj.timestamp} : \n ${nmeaObj.message}',
          style: const TextStyle(fontSize: 8)));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height / 3,
              minWidth: MediaQuery.of(context).size.width / 1.2),
          color: Colors.grey[200],
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: nmeaLog))),
    );
  }
}
