import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'package:scoreboard_controller/pages/game_control/view/game_control.dart';
import 'package:scoreboard_controller/pages/game_control/view/test_control.dart';
import 'package:scoreboard_controller/pages/home/controller/home_controller.dart';
// import 'dart:convert';
import 'dart:typed_data';

class SettingsPage extends StatefulWidget {
  // const HomePage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  final connectionController = Get.put(HomeController());
  var devices = <BluetoothDevice>[];

  @override
  void initState() {
    super.initState();
    _getBTState();
    _setStateChangeListener();
    _listBondedDevices();
  }

  _getBTState() {
    FlutterBluetoothSerial.instance.state.then((state) {
      _bluetoothState = state;
      setState(() {});
    });
  }

  _setStateChangeListener() {
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      _bluetoothState = state;
      setState(() {});
    });
  }

  _listBondedDevices() {
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      devices = bondedDevices
          .where((bd) =>
              bd.name.toString().startsWith("HC") ||
              bd.name.toString().startsWith("AT"))
          .toList();
      print(devices);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select ScoreBoard"),
        actions: [
          IconButton(
              onPressed: () {
                _listBondedDevices();
                setState(() {});
              },
              icon: Icon(IconData(0xe514, fontFamily: 'MaterialIcons'))),
        ],
      ),
      body: Container(
          child: Column(
        children: [
          SwitchListTile(
              title: Text("Bluetooth Toggle"),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                future() async {
                  if (value) {
                    FlutterBluetoothSerial.instance.requestEnable();
                  } else {
                    FlutterBluetoothSerial.instance.requestDisable();
                  }
                }

                future().then((_) {
                  setState(() {});
                });
              }),
          ListTile(
            title: Text("Bluetooth State"),
            subtitle: Text(_bluetoothState.stringValue),
            trailing: ElevatedButton(
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
              child: Text("SETTINGS"),
            ),
          ),
          Expanded(
              child: ListView(
            children: devices
                .map((_device) => ListTile(
                      title: Text(_device.name.toString()),
                      leading: Icon(Icons.bluetooth_connected),
                      subtitle: Obx(() => Text(
                          _device.address + '${connectionController.status}')),
                      trailing: IconButton(
                        icon: Icon(Icons.link),
                        onPressed: () {
                          if (connectionController.status.value) {
                            Get.to(TestControl());
                          } else {
                            connectionController.connectTo(_device);
                          }
                        },
                      ),
                    ))
                .toList(),
          )),
        ],
      )),
    );
  }

  // bool connectTo(BluetoothDevice server) {
  //   BluetoothConnection.toAddress(server.address).then((_connection) {
  //     Get.snackbar("SUCCESS", "Connected to ${server.name.toString()}");
  //     print("Connected to ${server.name.toString()}");
  //     connectionController.myconnection.value = _connection;
  //     connectionController.isConnecting.value = false;
  //     connectionController.isDisconnecting.value = false;
  //     connectionController.status.value = true;
  //     // setState(() {
  //     //   isConnecting = false;
  //     //   isDisconnecting = false;
  //     // });

  //     connectionController.myconnection.value!.input!
  //         .listen(_onDataReceived)
  //         .onDone(() {
  //       // Example: Detect which side closed the connection
  //       // There should be `isDisconnecting` flag to show are we are (locally)
  //       // in middle of disconnecting process, should be set before calling
  //       // `dispose`, `finish` or `close`, which all causes to disconnect.
  //       // If we except the disconnection, `onDone` should be fired as result.
  //       // If we didn't except this (no flag set), it means closing by remote.
  //       if (connectionController.isDisconnecting.value) {
  //         print('Disconnecting locally!');
  //       } else {
  //         print('Disconnected remotely!');
  //       }
  //       if (this.mounted) {
  //         setState(() {});
  //       }
  //     });

  //     return true;
  //   }).catchError((error) {
  //     Get.snackbar(
  //       "ERROR",
  //       "Couldn't Connect to ${server.name.toString()}",
  //     );

  //     print('Cannot connect, exception occured');
  //     print(error);
  //     return false;
  //     // Get.back();
  //   });
  //   return true;
  // }

  // void _onDataReceived(Uint8List data) {
  //   // Allocate buffer for parsed data
  //   int backspacesCounter = 0;
  //   data.forEach((byte) {
  //     if (byte == 8 || byte == 127) {
  //       backspacesCounter++;
  //     }
  //   });
  //   Uint8List buffer = Uint8List(data.length - backspacesCounter);
  //   int bufferIndex = buffer.length;

  //   // Apply backspace control character
  //   backspacesCounter = 0;
  //   for (int i = data.length - 1; i >= 0; i--) {
  //     if (data[i] == 8 || data[i] == 127) {
  //       backspacesCounter++;
  //     } else {
  //       if (backspacesCounter > 0) {
  //         backspacesCounter--;
  //       } else {
  //         buffer[--bufferIndex] = data[i];
  //       }
  //     }
  //   }
  // }
}
