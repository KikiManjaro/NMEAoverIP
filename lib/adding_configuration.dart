import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lan_scanner/lan_scanner.dart';
import 'package:nmea_to_network/ip.dart';
import 'package:toast/toast.dart';

class AddingConfiguration extends StatefulWidget {
  const AddingConfiguration({Key? key}) : super(key: key);

  @override
  AddingConfigurationState createState() => AddingConfigurationState();
}

class AddingConfigurationState extends State<AddingConfiguration> {
  NetworkType dropdownValue = NetworkType.UDP;
  TextEditingController ipController = TextEditingController(text: IP.subnet);
  TextEditingController portController = TextEditingController(text: '30304');

  AddingConfigurationState() {
    IP.addingConfigurationState = this;
  }

  @override
  void dispose() {
    IP.addingConfigurationState = null;
    IP.scanner = LanScanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[600],
        elevation: 20,
        title: const Text('Adding Configuration'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Form(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    DropdownButton<NetworkType>(
                      hint: const Text('Sending Method'),
                      value: dropdownValue,
                      items: [
                        DropdownMenuItem<NetworkType>(
                          child: Text(getNetworkTypeString(NetworkType.UDP)),
                          value: NetworkType.UDP,
                        ),
                        DropdownMenuItem<NetworkType>(
                          child:
                              Text(getNetworkTypeString(NetworkType.MULTICAST)),
                          value: NetworkType.MULTICAST,
                        ),
                      ],
                      onChanged: (NetworkType? value) {
                        setState(() {
                          dropdownValue = value!;
                          if (dropdownValue == NetworkType.MULTICAST) {
                            ipController.text =
                                IP.subnet != null ? '${IP.subnet}.255' : '';
                          } else {
                            ipController.text = IP.subnet ?? '';
                          }
                        });
                      },
                    ),
                    TextFormField(
                      controller: ipController,
                      decoration: const InputDecoration(
                        labelText: 'IP Address',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'IP to send to';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: portController,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Port to send to';
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ToastContext().init(context);
                        if (true) {
                          //TODO: set a real validator
                          IP.confList.add(IPConf(
                              dropdownValue,
                              ipController.text,
                              int.parse(portController.text)));
                          Toast.show("Configuration added",
                              duration: Toast.lengthShort,
                              gravity: Toast.bottom);
                          Navigator.pop(context);
                        } else {
                          Toast.show("Invalid",
                              duration: Toast.lengthShort,
                              gravity: Toast.bottom);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.grey[800],
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
            buildDevicesGrid(),
            ElevatedButton(
                onPressed: () => IP.discoverNetwork(),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.grey[800],
                  ),
                ),
                child: const Text("Search Devices")),
          ],
        ),
      ),
    );
  }

  Widget buildDevicesGrid() {
    List<Widget> children = [];
    for (var device in IP.networkDevices) {
      children.add(GestureDetector(
        onTap: () {
          ipController.text = device.ip;
        },
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.computer),
              Text(device.ip),
            ],
          ),
        ),
      ));
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, childAspectRatio: 1.0),
          children: children),
    );
  }
}
