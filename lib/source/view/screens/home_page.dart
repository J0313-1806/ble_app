import 'package:ble_app/source/constants/colors.dart';
import 'package:ble_app/source/constants/strings.dart';
import 'package:ble_app/source/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  static final HomeController _homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.white,
      appBar: buildAppBar(),
      body: buildStreamDevices(),
      floatingActionButton: buildActionButton(),
    );
  }

// Home page appbar
  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: const Text(
        StringConstants.appName,
        style: TextStyle(color: ColorConstants.black),
      ),
      actions: [
        _homeController.connectedDeviceList.isNotEmpty
            ? IconButton(
                onPressed: _homeController.toConnectedDevicesPage,
                icon: const Icon(
                  Icons.bluetooth_connected,
                  color: ColorConstants.blue,
                ),
              )
            : const Center(),
        IconButton(
          onPressed: _homeController.toConnectedDevicesPage,
          icon: const Icon(
            Icons.list,
            color: ColorConstants.blue,
          ),
        ),
      ],
      backgroundColor: ColorConstants.white,
      elevation: 0.0,
    );
  }

// Stream to build nearby Devices list
  Widget buildStreamDevices() {
    return StreamBuilder<BluetoothState>(
        stream: _homeController.bluePlus.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            _homeController.bluetoothToggle(true);
            return buildDeviceList();
          }
          _homeController.bluetoothToggle(false);
          return buildOffScreen(state: state);
        });
  }

// Device List
  Widget buildDeviceList() {
    return StreamBuilder<List<ScanResult>>(
      stream: _homeController.bluePlus.scanResults,
      initialData: const [],
      builder: (c, snapshot) => GestureDetector(
        onVerticalDragDown: _homeController.onScrollListener,
        child: ListView(
            controller: _homeController.deviceListScrollController,
            children: snapshot.data!.map((e) => buildDeviceTile(e)).toList()),
      ),
    );
  }

  // Custom Device Tile
  Widget buildDeviceTile(ScanResult device) {
    return Container(
      width: Get.width - 5,
      height: Get.height * 0.09,
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Row(
              children: <Widget>[
                const Icon(Icons.smartphone),
                const SizedBox(width: 5),
                Text(device.rssi.toString()),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(device.device.id.toString()),
                    Text(device.device.name.isEmpty
                        ? "unknown"
                        : device.device.name),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: <Widget>[
                OutlinedButton(
                    onPressed: () =>
                        _homeController.toDeviceDetail(device.device),
                    style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        fixedSize: const Size.fromWidth(110)),
                    child: Text(
                      _homeController.connectedDeviceInfo != null
                          ? StringConstants.connect
                          : StringConstants.open,
                      style: const TextStyle(color: ColorConstants.blue),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButton() {
    return Obx(
      () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _homeController.showFloatingButton.value
              ? FloatingActionButton(
                  onPressed: _homeController.scanDevices,
                  child: const Icon(
                    Icons.search,
                  ),
                )
              : const SizedBox()),
    );
  }

  Widget buildOffScreen({BluetoothState? state}) {
    return SizedBox(
      height: Get.height - 10,
      width: Get.width - 10,
      child: InkWell(
        onTap: () => _homeController.onToggleBluetooth(true),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: ColorConstants.blue,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
            ),
            const Text('TAP TO TURN ON'),
          ],
        ),
      ),
    );
  }
}
