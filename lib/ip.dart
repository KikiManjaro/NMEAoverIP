import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:lan_scanner/lan_scanner.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:nmea_to_network/adding_configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udp/udp.dart';

class IP {
  static LanScanner scanner = LanScanner();
  static LanScanner backgroundScanner = LanScanner();
  static late UDP sender;
  static late SharedPreferences prefs;
  static String? subnet = "";
  static List<HostModel> networkDevices = <HostModel>[];
  static AddingConfigurationState? addingConfigurationState;

  static List<IPConf> confList = <IPConf>[
    // IPConf(NetworkType.UDP, "192.168.0.33", 30304)
  ];

  static init() async {
    initPref();
    initSocket();
  }

  static initSocket() async {
    sender = await UDP.bind(Endpoint.any(port: const Port(33333)));
  }

  static initPref() async {
    prefs = await SharedPreferences.getInstance();
    final String? confs = prefs.getString('confList');
    if (confs != null) {
      confList.clear();
      var decodedConf = jsonDecode(confs) as List;
      for (var elem in decodedConf) {
        IPConf conf = IPConf.fromJson(elem);
        confList.add(conf);
      }
    }
  }

  static addConf(IPConf ipConf) async {
    confList.add(ipConf);
    await prefs.setString('confList', jsonEncode(confList));
  }

  static void remove(IPConf conf) async {
    confList.remove(conf);
    await prefs.setString('confList', jsonEncode(confList));
  }

  static Future<void> sendUDPMessage(String message) async {
    for (var conf in confList) {
      if (conf.type == NetworkType.UDP) {
        try {
          await sender.send(
              message.codeUnits,
              Endpoint.unicast(InternetAddress(conf.ip),
                  port: Port(conf.port)));
        } catch (e) {
          print('Error while sending UDP $e');
        }
      }
    }
  }

  static Future<void> sendMulticastMessage(String message) async {
    for (var conf in confList) {
      if (conf.type == NetworkType.MULTICAST) {
        try {
          await sender.send(
              message.codeUnits,
              Endpoint.multicast(InternetAddress(conf.ip),
                  port: Port(conf.port)));
        } catch (e) {
          print('Error while sending Multicast $e');
        }
      }
    }
  }

  static Uint8List toBytes(String str) {
    Uint8List bytes = Uint8List(str.length);
    for (int i = 0; i < str.length; i++) {
      bytes[i] = str.codeUnitAt(i);
    }
    return bytes;
  }

  static Future<List<HostModel>> discoverNetwork() async {
    await findSubnet();
    if (subnet == null) {
      print('No wifi network found');
    } else {
      scan(scanner, nbProc: Platform.numberOfProcessors);
    }
    return networkDevices;
  }

  static discoverNetworkBackground() async {
    if (Platform.numberOfProcessors > 3) {
      await findSubnet();
      if (subnet == null) {
        print('No wifi network found');
      } else {
        scan(backgroundScanner,
            // nbProc: (Platform.numberOfProcessors / 2).floor()
        );
      }
      return networkDevices;
    }
  }

  static void scan(LanScanner scan, {int nbProc = 1}) async {
    if (!scan.isScanInProgress) {
      final stream = scan.icmpScan(
        subnet!,
        // timeout: const Duration(milliseconds: 200),
        scanThreads: nbProc,
        progressCallback: (progress) {
          print('progress: $progress');
        },
      );
      stream.listen((HostModel host) {
        var toAdd = true;
        for (var device in networkDevices) {
          if (device.ip == host.ip) {
            toAdd = false;
          }
        }
        if (toAdd) {
          networkDevices.add(host);
          if (host.ip != InternetAddress(host.ip).host) {
            print('Found device: ${InternetAddress(host.ip).host}');
          }
          print('Found device: $host');
          addingConfigurationState?.setState(() {});
        }
      }, onDone: () {
        print('Scan completed');
        networkDevices.sort((a, b) => a.ip.compareTo(b.ip));
        addingConfigurationState?.setState(() {});
      });
    }
  }

  static Future<String?> findSubnet() async {
    // WidgetsFlutterBinding.ensureInitialized();
    final String? ip = await NetworkInfo().getWifiIP();
    subnet = ip?.substring(0, ip.lastIndexOf('.'));
    return subnet;
  }
}

class IPConf {
  NetworkType type;
  String ip;
  int port;

  IPConf(this.type, this.ip, this.port);

  // IPConf.fromJson(Map<String, dynamic> json)
  //     : type = NetworkType.UDP.toString() == json['type']
  //           ? NetworkType.UDP
  //           : NetworkType.MULTICAST,
  //       ip = json['ip'],
  //       port = int.parse(json['port']);

  factory IPConf.fromJson(Map<String, dynamic> json) =>
      IPConf(
          NetworkType.UDP.toString() == json['type']
              ? NetworkType.UDP
              : NetworkType.MULTICAST,
          json['ip'],
          int.parse(json['port']));

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'ip': ip,
      'port': port.toString(),
    };
  }
}

enum NetworkType { UDP, MULTICAST }

String getNetworkTypeString(NetworkType type) {
  switch (type) {
    case NetworkType.UDP:
      return 'UDP';
    case NetworkType.MULTICAST:
      return 'MULTICAST';
    default:
      return 'UNKNOWN';
  }
}
