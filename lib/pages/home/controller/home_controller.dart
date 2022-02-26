import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import 'dart:typed_data';

import 'package:scoreboard_controller/pages/game_control/view/test_control.dart';

class HomeController extends GetxController {
  final myconnection = Rxn<BluetoothConnection>();
  final status = false.obs;
  final isConnecting = true.obs;
  final isDisconnecting = false.obs;

  void connectTo(BluetoothDevice server) {
    BluetoothConnection.toAddress(server.address).then((_connection) {
      Get.snackbar("SUCCESS", "Connected to ${server.name.toString()}");
      print("Connected to ${server.name.toString()}");
      myconnection.value = _connection;
      isConnecting.value = false;
      isDisconnecting.value = false;
      status.value = true;

      if (status.value) {
        Get.to(TestControl());
      }
      // setState(() {
      //   isConnecting = false;
      //   isDisconnecting = false;
      // });

      myconnection.value!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting.value) {
          print('Disconnecting locally!');
          status.value = false;
        } else {
          status.value = false;
          print('Disconnected remotely!');
        }
        // if (this.mounted) {
        //   setState(() {});
        // }
      });

      return true;
    }).catchError((error) {
      Get.snackbar(
        "ERROR",
        "Couldn't Connect to ${server.name.toString()}",
      );

      print('Cannot connect, exception occured');
      print(error);
      return false;
      // Get.back();
    });
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

  // var myconnection = connection;
}
