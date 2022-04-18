import 'dart:io';
import 'dart:typed_data';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:network_tools/network_tools.dart';
import 'package:udp/udp.dart';

class IP {
  static late UDP sender;
  static String? subnet = "";
  static Set<ActiveHost> networkDevices = <ActiveHost>{};

  static List<IPConf> confList = <IPConf>[
    IPConf(NetworkType.UDP, "192.168.0.33", 33334)
  ];

  static Future<void> initSocket() async {
    sender = await UDP.bind(Endpoint.any(port: const Port(33333)));
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
          print(e);
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
          print(e);
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

  static Future<Set<ActiveHost>> discoverNetwork() async {
    networkDevices.clear();
    await findSubnet();
    if (subnet == null) {
      print('No wifi network found');
    } else {
      final stream =
          HostScanner.discover(subnet!, progressCallback: (progress) {
        print('Progress for host discovery : $progress');
      });

      stream.listen((host) {
        networkDevices.add(host);
        print('Found device: ${host}');
      }, onDone: () {
        print('Scan completed');
      });
    }
    return networkDevices;
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
