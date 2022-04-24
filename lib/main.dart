import 'package:background_mode_new/background_mode_new.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nmea_to_network/configuration.dart';
import 'package:nmea_to_network/ip.dart';
import 'package:nmea_to_network/location_data.dart';
import 'package:nmea_to_network/map.dart';
import 'package:nmea_to_network/nmea.dart';

void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    builder: (context, child) {
      BackgroundMode.start();
      IP.initSocket();
      IP.discoverNetworkBackground();
      NMEA.initNmeaReading();
      return Directionality(textDirection: TextDirection.ltr, child: child!);
    },
    title: 'NMEAoverIP',
    theme: ThemeData(
      primaryColor: Colors.grey[800],
    ),
    home: const MainState()));

class MainState extends StatefulWidget {
  const MainState({Key? key}) : super(key: key);

  @override
  _MainStateState createState() => _MainStateState();
}

class _MainStateState extends State<MainState> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static final List<Widget> _widgetOptions = <Widget>[
    const CustomMap(),
    const LocationData(),
    const Configuration(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[600],
        elevation: 20,
        title: const Text('NMEA Over IP'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: const [
                GButton(
                  icon: LineIcons.locationArrow,
                  text: 'Location',
                ),
                GButton(
                  icon: LineIcons.info,
                  text: 'Info',
                ),
                GButton(
                  icon: LineIcons.edit,
                  text: 'Configuration',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
