import 'dart:convert';
import 'dart:developer';

import 'package:ble_app/source/constants/colors.dart';
import 'package:ble_app/source/constants/strings.dart';
import 'package:ble_app/source/controller/home_controller.dart';
import 'package:ble_app/source/controller/nearby_api_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class NearbyHome extends StatefulWidget {
  const NearbyHome({super.key});

  static final NearbyApiController _nearbyApiController = Get.find();
  static final HomeController _homeController = Get.find();

  static final BluetoothDevice deviceInfo =
      Get.arguments ?? _homeController.connectedDeviceInfo;

  static final simpleBlue = _homeController.simpleBlue;

  @override
  State<NearbyHome> createState() => _NearbyHomeState();
}

class _NearbyHomeState extends State<NearbyHome> {
  @override
  void initState() {
    NearbyHome.simpleBlue.listenConnectedDevice().listen((connectedDevice) {
      connectedDevice?.stream?.listen((received) {
        setState(() {
          receivedData +=
              "${DateTime.now().toString()}: ${utf8.decode(received)}";
        });
      });
    }).onError((err) {
      log("simpleblue error: $err");
    });
    log(receivedData);
    super.initState();
  }

  var receivedData = 'null';
  var uuid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ElevatedButton(
          onPressed: () => NearbyHome._homeController
              .onDisconnectDevice(NearbyHome.deviceInfo),
          child: const Text("Disconnect"),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // await NearbyHome.simpleBlue
              //     .write(uuid.toString(), utf8.encode("hello"))
              //     .whenComplete(() {
              //   log("message");
              // }).onError((error, stackTrace) =>
              //         log("simple blue write: error: $error"));
            },
            icon: const Icon(Icons.message),
            color: ColorConstants.blue,
          ),
        ],
        centerTitle: true,
        backgroundColor: ColorConstants.white,
        elevation: 0.0,
      ),
      body: ListView(shrinkWrap: true, primary: false, children: [
        ExpansionTile(
          title: Text(NearbyHome.deviceInfo.name),
          subtitle: Text(
            NearbyHome.deviceInfo.id.toString(),
          ),
          children: List.generate(
            NearbyHome._homeController.deviceServices.length,
            (serviceIndex) {
              var service =
                  NearbyHome._homeController.deviceServices[serviceIndex];
              return ExpansionTile(
                title: Text(service.deviceId.id),
                subtitle: const Text("Charactersitics"),
                children: List.generate(
                  service.characteristics.length,
                  (characterIndex) {
                    var characteristic =
                        service.characteristics[characterIndex];

                    return ExpansionTile(
                      title: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("can read?"),
                              characteristic.properties.read
                                  ? IconButton(
                                      onPressed: () async {
                                        await characteristic
                                            .setNotifyValue(true);
                                        characteristic.value.listen((value) {
                                          String newVal = utf8.decode(value);
                                          log("reading: $newVal");
                                        }).onError((error) =>
                                            log("reading error: $error"));
                                      },
                                      icon: const Icon(Icons.call_received),
                                    )
                                  : Text(
                                      characteristic.properties.read.toString(),
                                    ),
                            ],
                          ),
                          const SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("can write without response?"),
                              Text(
                                characteristic.properties.writeWithoutResponse
                                    .toString(),
                              ),
                              const Text("can write?"),
                              characteristic.properties.write
                                  ? IconButton(
                                      onPressed: () async {
                                        uuid = characteristic.uuid;
                                        log("uuid: ${characteristic.uuid}");
                                        var value =
                                            utf8.encode("Hello from me!");
                                        await characteristic
                                            .write(value)
                                            .onError((error, stackTrace) {
                                          log("send error: $error");
                                        });
                                      },
                                      icon: const Icon(Icons.send),
                                    )
                                  : Text(
                                      characteristic.properties.write
                                          .toString(),
                                    ),
                            ],
                          ),
                        ],
                      ),
                      children: List.generate(
                        characteristic.descriptors.length,
                        (discriptorIndex) {
                          var descriptors =
                              characteristic.descriptors[discriptorIndex];

                          return ExpansionTile(
                            subtitle: Text(
                              descriptors.characteristicUuid.toString(),
                            ),
                            title: const Text("Descriptor characteristic uuid"),
                            children: [
                              characteristic.properties.write
                                  ? ElevatedButton(
                                      onPressed: () {},
                                      child: const Text("Write"),
                                    )
                                  : const Center(),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        NearbyHome._nearbyApiController.devices.isEmpty
            ? const Center()
            : ListView.builder(
                shrinkWrap: true,
                itemCount: NearbyHome._nearbyApiController.devices.length,
                itemBuilder: (context, index) {
                  final device = NearbyHome._nearbyApiController.devices[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(device.name),
                      trailing: device.isConnected
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: device.isConnected
                                  ? const Text("Connected")
                                  : const Text("Not connected"),
                            ),
                    ),
                  );
                }),
      ]),
    );
  }
}
