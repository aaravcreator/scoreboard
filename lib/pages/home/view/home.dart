import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoreboard_controller/pages/settings/view/settings.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage'),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(SettingsPage());
              },
              icon: Icon(Icons.settings))
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(onPressed: () {}, child: Text("Go to Controller"))
        ],
      ),
    );
  }
}
