import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nmea_to_network/nmea.dart';

class LocationData extends StatefulWidget {
  const LocationData({Key? key}) : super(key: key);

  @override
  State<LocationData> createState() => _LocationDataState();
}

class _LocationDataState extends State<LocationData> {
  bool _hasPermissions = false;
  CompassEvent? _lastRead;
  DateTime? _lastReadAt;

  _LocationDataState() {
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
            buildInfoGrid(),
            nmeaLogger(),
            // _buildCompass(),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget nmeaLogger() {
    var nmeaLog = <Widget>[];
    for (var nmeaObj in NMEA.nmeaList) {
      nmeaLog.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Divider(
            height: 3,
          ),
          Text('${nmeaObj.timestamp} :',
              style: const TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold)),
          Text(nmeaObj.message, style: const TextStyle(fontSize: 10)),
        ],
      ));
    }
    return Center(
      child: Card(
        elevation: 4,
        // color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [Colors.transparent, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment(0.0, -0.3),
              ).createShader(bounds);
            },
            child: Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height / 3,
                  minWidth: MediaQuery.of(context).size.width / 1.2),
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: nmeaLog),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoGrid() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 1.5),
        children: <Widget>[
          Card(
            elevation: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.gps_fixed),
                const SizedBox(height: 6),
                Text('Latitude: ${NMEA.pos.latitude}'),
                Text('Longitude: ${NMEA.pos.longitude}'),
              ],
            ),
          ),
          Card(
            elevation: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(LineIcons.compass),
                const SizedBox(height: 6),
                Text('Heading: ${NMEA.pos.heading.toStringAsFixed(2)}°'),
              ],
            ),
          ),
          Card(
            elevation: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.height),
                const SizedBox(height: 6),
                Text('Altitude: ${NMEA.pos.altitude.toStringAsFixed(2)}m'),
              ],
            ),
          ),
          Card(
            elevation: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.speed),
                const SizedBox(height: 6),
                Text('Speed: ${NMEA.pos.speed.toStringAsFixed(2)} m/s'),
                Text(
                    'Accuracy: ${NMEA.pos.speedAccuracy.toStringAsFixed(2)} m/s'),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Widget _buildCompass() { //TODO: find a compass.png and use it
//   return StreamBuilder<CompassEvent>(
//     stream: FlutterCompass.events,
//     builder: (context, snapshot) {
//       if (snapshot.hasError) {
//         return Text('Error reading heading: ${snapshot.error}');
//       }
//
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return Center(
//           child: CircularProgressIndicator(),
//         );
//       }
//
//       double? direction = snapshot.data!.heading;
//
//       // if direction is null, then device does not support this sensor
//       // show error message
//       if (direction == null)
//         return Center(
//           child: Text("Device does not have sensors !"),
//         );
//
//       return Material(
//         shape: CircleBorder(),
//         clipBehavior: Clip.antiAlias,
//         elevation: 4.0,
//         child: Container(
//           padding: EdgeInsets.all(16.0),
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//           ),
//           child: Transform.rotate(
//             angle: (direction * (pi / 180) * -1),
//             child: Image.asset('assets/compass.jpg'),
//           ),
//         ),
//       );
//     },
//   );
// }
}
