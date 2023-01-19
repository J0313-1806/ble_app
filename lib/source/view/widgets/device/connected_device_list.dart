import 'package:ble_app/source/controller/home_controller.dart';
import 'package:ble_app/source/view/screens/nearby_home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectedDeviceList extends StatelessWidget {
  const ConnectedDeviceList({super.key});

  static final HomeController _homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connected Devices"),
        elevation: 0.0,
      ),
      body: ListView.builder(
        itemCount: _homeController.connectedDeviceList.length,
        itemBuilder: (context, index) {
          var device = _homeController.connectedDeviceList[index];
          return ListTile(
            title: Text(device.name),
            onTap: () {
              Get.to(() => const NearbyHome(), arguments: device);
            },
          );
        },
      ),
    );
  }
}
