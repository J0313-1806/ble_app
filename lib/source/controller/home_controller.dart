import 'dart:developer';
import 'dart:io';
import 'package:ble_app/source/controller/nearby_api_controller.dart';
import 'package:ble_app/source/view/device/connected_device_list.dart';
import 'package:ble_app/source/view/home/home_page.dart';
import 'package:ble_app/source/view/home/nearby_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simpleblue/simpleblue.dart';
// import 'package:simpleblue/simpleblue.dart';

class HomeController extends GetxController {
  @override
  void onReady() async {
    super.onReady();

    // simplebluePlugin.listenConnectedDevice().listen((connectedDevice) {
    //   log("Connected device: $connectedDevice");

    //   if (connectedDevice != null) {
    //     // deviceList[connectedDevice.uuid] = connectedDevice;
    //   }

    //   connectedDevice?.stream?.listen((received) {
    //     // receivedData += "${DateTime.now().toString()}: $received\n";
    //   });
    // }).onError((err) {
    //   log("listening on connected Device error: $err");
    // });
    await bluePlus.isOn ? scanDevices() : null;
  }

// initializing bluetooth plus library
  var bluePlus = FlutterBluePlus.instance;
// initializing simpleBlue library
  final simpleBlue = Simpleblue();

  ScrollController deviceListScrollController = ScrollController();

  RxBool checkBluetoothPermission = RxBool(false);
  RxBool checkLocationPersmission = RxBool(false);

  RxBool bluetoothToggle = RxBool(false);

  /// list of screen for bottom navigation
  List<Widget> pages = [const MyHomePage(), const NearbyHome()];

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

  /// takes to the device information page
  void onConnect(BluetoothDevice device) async {
    hostName(device.id.id);
    fetchingService(true);
    connectedDeviceInfo == null
        ? await device.connect().whenComplete(() async {
            connectedDeviceInfo = device;
            deviceServices.value = await device.discoverServices();
            log("device type: ${device.type}");

            Get.to(() => const NearbyHome(), arguments: device);
          }).catchError((onError) => log("cannot connect to device: $onError"))
        : log("maybe already connected");

    fetchingService(false);
    connectedDeviceList.value = await bluePlus.connectedDevices;
    log("Connected Devices: ${await bluePlus.connectedDevices}");
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

        hostName.value = await bluePlus.name;
        log("host name: ${hostName.string}");

        for (var device in connectedDevices) {
          deviceList.putIfAbsent(device.id.toString(), () => device);
        }

        Get.put(NearbyApiController());
        // deviceList(event);

        //   simplebluePlugin
        //       .scanDevices(serviceUUID: serviceUUID.value, timeout: 15000)
        //       .listen((devices) {
        //     for (var device in devices) {
        //       log(device.uuid);
        //       deviceList[device.uuid] = device;
        //     }
        //   });
      }
      // simplebluePlugin.getDevices().then((value) {
      //   for (var device in value) {
      //     deviceList[device.uuid] = device;
      //     log("${device.name} ${device.isConnected ? "is Connected" : "is not Connected"} ");
      //   }
      // });
    }
  }

  RxInt pageIndex = RxInt(0);
  void bottomNavTap(int index) {
    pageIndex(index);
  }

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
