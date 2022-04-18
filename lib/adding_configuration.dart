import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nmea_to_network/ip.dart';
import 'package:toast/toast.dart';

class AddingConfiguration extends StatefulWidget {
  const AddingConfiguration({Key? key}) : super(key: key);

  @override
  _AddingConfigurationState createState() => _AddingConfigurationState();
}

class _AddingConfigurationState extends State<AddingConfiguration> {
  NetworkType dropdownValue = NetworkType.UDP;
  TextEditingController ipController = TextEditingController(text: IP.subnet);
  TextEditingController portController = TextEditingController(text: '');


  _AddingConfigurationState(){
    // compute(IP.discoverNetwork, null); //TODO: move somewhere else maybe
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adding Configuration'),
      ),
      body: Column(
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
                        child: Text(getNetworkTypeString(NetworkType.MULTICAST)),
                        value: NetworkType.MULTICAST,
                      ),
                    ],
                    onChanged: (NetworkType? value) {
                      setState(() {
                        dropdownValue = value!;
                        //TODO: change bottom widget
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
                        IP.confList.add(IPConf(dropdownValue, ipController.text,
                            int.parse(portController.text)));
                        Toast.show("Configuration added",
                            duration: Toast.lengthShort, gravity: Toast.bottom);
                        Navigator.pop(context);
                      } else {
                        Toast.show("Invalid",
                            duration: Toast.lengthShort, gravity: Toast.bottom);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
          ),
          // FutureBuilder(
          //   future: IP.discoverNetwork(),
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       return const Text("OK");
          //     } else if (snapshot.hasError) {
          //       return const Text("No Devices Found");
          //     }
          //     return const CircularProgressIndicator();
          //   },
          // ),
        ],
      ),
    );
  }
}
