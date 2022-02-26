import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class GameControl extends StatefulWidget {
  final BluetoothDevice server;

  const GameControl({required this.server});

  @override
  _GameControlState createState() => _GameControlState(server);
}

class _GameControlState extends State<GameControl> {
  BluetoothConnection? connection;

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);
  bool isDisconnecting = false;
  BluetoothDevice server;
  _GameControlState(this.server);

  TextEditingController textbox = TextEditingController();
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    BluetoothConnection.toAddress(server.address).then((_connection) {
      Get.snackbar("SUCCESS", "Connected to ${server.name.toString()}");
      print("Connected to ${server.name.toString()}");
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      Get.snackbar(
        "ERROR",
        "Couldn't Connect to ${server.name.toString()}",
      );
      print('Cannot connect, exception occured');
      print(error);
      // Get.back();
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return
        // appBar: AppBar(
        //   title: Text("To: ${server.name.toString()},s:${isConnected}"),
        // ),
        Scaffold(
      // padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Connection Status: ${isConnected} , ${server.isBonded}"),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: textbox,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter text to send',
                  errorText: errorCheck(textbox.text)),
            ),
          ),
          Container(
            height: 70,
            width: 70,
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                _sendMessage(textbox.text);
                print(textbox.text);
                textbox.clear();
              },
              // style: ElevatedButton.styleFrom(shape: CircleBorder()),
            ),
            // decoration: BoxDecoration(
            //   color: Colors.green,
            //   borderRadius: BorderRadius.circular(25),
            // )
          ),
          Container(
            height: 70,
            width: 70,
            child: ElevatedButton(
              child: Text("test"),
              onPressed: () {
                print("Test Pressed!");
                _sendMessage("S");
              },
              style: ElevatedButton.styleFrom(shape: CircleBorder()),
            ),
            // decoration: BoxDecoration(
            //   color: Colors.green,
            //   borderRadius: BorderRadius.circular(25),
            // )
          )
        ],
      ),
    );
  }

  String errorCheck(String value) {
    if (!(value.length > 5) && value.isNotEmpty) {
      return "Password should contain more than 5 characters";
    } else {
      return "";
    }
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }
  }

  void _sendMessage(String text) async {
    if (isConnected) {
      text = text.trim();

      if (text.length > 0) {
        try {
          // connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
          connection!.output.add(Uint8List.fromList(utf8.encode(text)));

          await connection!.output.allSent;

          setState(() {
            // messages.add(_Message(clientID, text));
          });

          // Future.delayed(Duration(milliseconds: 333)).then((_) {
          //   listScrollController.animateTo(
          //       listScrollController.position.maxScrollExtent,
          //       duration: Duration(milliseconds: 333),
          //       curve: Curves.easeOut);
          // });
        } catch (e) {
          Get.snackbar("ERROR", "Disconnected!");
          // Ignore error, but notify state
          setState(() {});
        }
      }
    } else {
      Get.snackbar("ERROR", "Disconnected!");
    }
  }
}
