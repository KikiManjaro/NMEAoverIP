import 'package:flutter/material.dart';
import 'package:nmea_to_network/adding_configuration.dart';
import 'package:nmea_to_network/ip.dart';

class Configuration extends StatefulWidget {
  const Configuration({Key? key}) : super(key: key);

  @override
  State<Configuration> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: getConfList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[800],
        onPressed: () => createIP(),
        tooltip: 'Create Conf.',
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> getConfList() {
    var confList = <Widget>[];
    IP.confList.sort((a, b) => a.type.index > b.type.index ? 1 : -1);
    for (var conf in IP.confList) {
      confList.add(
        ListTile(
          title: Text(getNetworkTypeString(conf.type)),
          subtitle: Text(conf.ip + ":" + conf.port.toString()),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => setState(() {
              IP.confList.remove(conf);
            }),
          ),
        ),
      );
    }
    return confList;
  }

  void createIP() {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddingConfiguration()))
        .then((_) => setState(() {}));
  }
}
