import 'dart:developer';
import 'dart:io';
import 'package:ble_app/source/controller/nearby_api_controller.dart';
import 'package:ble_app/source/view/screens/nearby_home.dart';
import 'package:ble_app/source/view/widgets/device/connected_device_list.dart';
import 'package:ble_app/source/view/screens/device_details.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:simpleblue/simpleblue.dart';

class HomeController extends GetxController {
  @override
  void onReady() async {
    super.onReady();

    await bluePlus.isOn ? scanDevices() : null;
  }

// initializing bluetooth plus library
  var bluePlus = FlutterBluePlus.instance;
// initializing simpleBlue library
  // final simpleBlue = Simpleblue();

  ScrollController deviceListScrollController = ScrollController();

  RxBool checkBluetoothPermission = RxBool(false);
  RxBool checkLocationPersmission = RxBool(false);

  RxBool bluetoothToggle = RxBool(false);

  /// to turn on/off bluetooth
  void onToggleBluetooth(bool value) async {
    // if (await bluetoothPlus.isAvailable) {
    bluetoothToggle(value);
    if (value) {
      await bluePlus.turnOn();
    } else {
      bluePlus.turnOff();
    }
    // }
  }

  /// Text controller for message
  var writeController = TextEditingController();

  ///takes unique device id
  RxString hostName = RxString("");

  /// showing the loader while fetching device services
  RxBool fetchingService = RxBool(false);

  /// list of device services
  RxList<BluetoothService> deviceServices = RxList([]);

  /// connected device
  BluetoothDevice? connectedDeviceInfo;

  /// List of connected Devices
  RxList<BluetoothDevice> connectedDeviceList = RxList([]);

  /// Connected Device ID
  RxString deviceID = RxString("");

  /// Checks whether device is connected to device
  RxBool isConnected = RxBool(false);

  /// takes to the device information page
  void onConnect(BluetoothDevice device) async {
    // hostName(device.id.id);
    fetchingService(true);
    if (connectedDeviceInfo == null) {
      await device.connect().then((value) async {
        connectedDeviceInfo = device;
        deviceServices.value = await device.discoverServices();
        isConnected(true);

        log("device type: ${device.type}");
      }).catchError((onError, stack) {
        isConnected(false);
        log("cannot connect to device: $onError");
      });
    } else {
      Get.snackbar(
          "Check connected Devices list", "Maybe its already connected");

      connectedDeviceList.value = await bluePlus.connectedDevices;
      if (connectedDeviceList.isEmpty) {
        connectedDeviceInfo = null;
        log("not connected device found");
      } else {
        log("maybe already connected");
      }
    }

    fetchingService(false);
    // connectedDeviceList.value = await bluePlus.connectedDevices;
    log("Connected Devices: $connectedDeviceList");
  }

  /// disconnects from device
  void onDisconnectDevice(BluetoothDevice device) async {
    await device
        .disconnect()
        .onError(
          (error, stackTrace) =>
              log('Error while disconnecting device: $error'),
        )
        .whenComplete(() => Get.back());
  }

  /// To See connected Devices
  void toConnectedDevicesPage() {
    log(connectedDeviceList.toString());
    connectedDeviceList.isNotEmpty
        ? Get.to(() => const ConnectedDeviceList())
        : null;
    connectedDeviceList.isNotEmpty
        ? null
        : Get.snackbar("Not Connected", "No connected devices found");
  }

  /// To see device Detail page
  void toDeviceDetail(BluetoothDevice device) {
    deviceID(device.id.id);
    Get.to(() => const DeviceDetailPage(), arguments: device);
  }

  /// For sending messages
  void onSendMessage() {}

  /// for recieving messages
  void onReceiveMessage() {
//     await characteristic.setNotifyValue(true);
// characteristic.value.listen((value) {
    // do something with new value
// });
    // bluePlus.
  }

  // RxString serviceUUID = RxString("");
  /// list of bluetooth devices with their unique ids
  RxMap<String, BluetoothDevice> deviceList = RxMap({});

  /// scanning for nearby devices
  void scanDevices() async {
    final isBluetoothGranted = Platform.isIOS ||
        (await Permission.bluetooth.status) == PermissionStatus.granted ||
        (await Permission.bluetooth.request()) == PermissionStatus.granted;

    if (isBluetoothGranted) {
      log("Bluetooth permission granted");

      final isLocationGranted = Platform.isIOS ||
          (await Permission.location.status) == PermissionStatus.granted ||
          (await Permission.location.request()) == PermissionStatus.granted;

      if (isLocationGranted) {
        log("Location permission granted");

        bluePlus.startScan(timeout: const Duration(seconds: 5));

        var connectedDevices = await bluePlus.connectedDevices;
// hostName.value =: Platform.isIOS ? await  DeviceInfoPlugin().iosInfo.utsname.machine : nul
        AndroidDeviceInfo androidDeviceInfo =
            await DeviceInfoPlugin().androidInfo;
        var host = androidDeviceInfo.model;

        log("host name: $host");

        for (var device in connectedDevices) {
          deviceList.putIfAbsent(device.id.toString(), () => device);
        }
      }
    }
  }

  /// Bottom navigation
  RxInt pageIndex = RxInt(0);
  void bottomNavTap(int index) {
    if (index == 1) {
      Get.put(NearbyApiController());
      Get.to(() => const NearbyHome());
    }
    pageIndex(index);
  }

  /// To hide floating action button on scroll
  RxBool showFloatingButton = RxBool(true);
  void onScrollListener(DragDownDetails details) {
    deviceListScrollController.addListener(() {
      if (deviceListScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (showFloatingButton.value) {
          // only set when the previous state is false
          showFloatingButton(false);
        }
      } else {
        if (deviceListScrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (!showFloatingButton.value) {
            showFloatingButton(true);
          }
        }
      }
    });
  }
}
