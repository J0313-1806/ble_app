import 'package:ble_app/source/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavHome extends StatelessWidget {
  const NavHome({super.key});
  static final HomeController _homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: _homeController.pages[_homeController.pageIndex.value],
        bottomNavigationBar: buildBottomNav(),
      ),
    );
  }

  Widget buildBottomNav() {
    return BottomNavigationBar(
      onTap: _homeController.bottomNavTap,
      items: List.generate(
        2,
        (index) => BottomNavigationBarItem(
            icon: Icon(
              index == 0 ? Icons.home : Icons.bluetooth_audio_rounded,
            ),
            label: ""),
      ),
    );
  }
}
 // ListView(
      //   shrinkWrap: true,
      //   primary: false,
      //   children: <Widget>[
      //     _buildNearbyConnection(),
      //     _homeController.bluetoothToggle.value
      //         ? buildDeviceList()
      //         : const Center(),
      //   ],
      // ),