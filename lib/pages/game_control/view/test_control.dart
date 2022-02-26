import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoreboard_controller/pages/home/controller/home_controller.dart';

class TestControl extends StatelessWidget {
  // const TestControl({Key? key}) : super(key: key);
  final HomeController merocontroller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("controller"),
      ),
      body: Container(
        child: Text("Hello WORLD ${merocontroller.status.value}"),
      ),
    );
  }
}
