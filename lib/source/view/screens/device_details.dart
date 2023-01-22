import 'dart:convert';
import 'dart:developer';
import 'dart:math' as random_math;
import 'package:ble_app/source/constants/colors.dart';
import 'package:ble_app/source/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class DeviceDetailPage extends StatelessWidget {
  const DeviceDetailPage({super.key});

  static final HomeController _homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_homeController.deviceID.value),
      ),
      body: Obx(
        () => _homeController.isConnected.value
            ? ListView.builder(
                itemCount: _homeController.deviceServices.length,
                itemBuilder: (context, serviceIndex) {
                  var service = _homeController.deviceServices[serviceIndex];
                  var services = service.includedServices;
                  log("services included: $services");
                  return ExpansionTile(
                    title: Text(service.uuid.toString()),
                    children: List.generate(
                      service.characteristics.length,
                      (chIndex) {
                        var characteristics = service.characteristics[chIndex];
                        return ExpansionTile(
                          title: Text(
                            characteristics.uuid.toString(),
                          ),
                          subtitle: Text(
                            characteristics.serviceUuid.toString(),
                          ),
                          children: [
                            Row(
                              children: <Widget>[
                                ..._buildReadWriteNotifyButton(characteristics),
                              ],
                            ),
                            ...buildDescriptorList(characteristics.descriptors),
                          ],
                        );
                      },
                    ),
                  );
                },
              )
            : const Text(
                "Something went wrong Or\nTry connecting using the floating button"),
      ),
      floatingActionButton: buildFAB(),
    );
  }

  List<Widget> _buildReadWriteNotifyButton(
    BluetoothCharacteristic characteristic,
  ) {
    List<ButtonTheme> buttons = <ButtonTheme>[];

    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextButton(
              child: const Text('READ', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  // setState(() {
                  //  widget.readValues[characteristic.uuid] = value;
                  // });
                });
                var received = await characteristic.read();
                var receivedString = utf8.decode(received);

                Get.snackbar("Received Message", receivedString,
                    backgroundColor: Colors.white);
                sub.cancel();
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              child: const Text('WRITE', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await showDialog(
                    context: Get.context!,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Write"),
                        content: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _homeController.writeController,
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Send"),
                            onPressed: () {
                              characteristic.write(utf8.encode(
                                  _homeController.writeController.value.text));
                              log("message : ${utf8.encode(_homeController.writeController.value.text)}");
                              Get.snackbar("Message Sent!", "",
                                  backgroundColor: Colors.white);
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              child:
                  const Text('NOTIFY', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                characteristic.value.listen((value) async {
                  // setState(() {
                  // [characteristic.uuid] = value
                  await characteristic.setNotifyValue(true);
                  Get.snackbar("Notification Set for",
                      "characteristic.uuid\n${characteristic.uuid}",
                      backgroundColor: Colors.white);
                  // });
                  log("message: ${characteristic.uuid}: ${utf8.decode((value))}");
                });
                await characteristic.setNotifyValue(true);
              },
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  Widget buildFAB() {
    return Obx(
      () => FloatingActionButton(
        onPressed: () {
          if (!_homeController.isConnected.value) {
            _homeController.onConnect(Get.arguments);
          } else {
            _homeController.onDisconnectDevice(
                Get.arguments ?? _homeController.connectedDeviceInfo);
          }
        },
        child: _homeController.fetchingService.value
            ? const CircularProgressIndicator(color: ColorConstants.white)
            : _homeController.isConnected.value
                ? const Icon(
                    Icons.link,
                    color: ColorConstants.white,
                  )
                : const Icon(
                    Icons.link_off,
                    color: ColorConstants.white,
                  ),
      ),
    );
  }

  List<Widget> buildDescriptorList(List<BluetoothDescriptor> descriptors) {
    List<int> getRandomBytes() {
      final math = random_math.Random();
      return [
        math.nextInt(255),
        math.nextInt(255),
        math.nextInt(255),
        math.nextInt(255)
      ];
    }

    return List.generate(descriptors.length, (index) {
      BluetoothDescriptor descriptor = descriptors[index];
      return DescriptorTile(
        descriptor: descriptor,
        onReadPressed: () async {
          var received = await descriptor.read();
          var receivedString = utf8.decode(received);
          Get.snackbar("read ${descriptor.uuid}", "received: $receivedString",
              backgroundColor: Colors.white);
        },
        onWritePressed: () => descriptor.write(getRandomBytes()),
      );
    });
  }
}

class DescriptorTile extends StatelessWidget {
  final BluetoothDescriptor descriptor;
  final VoidCallback? onReadPressed;
  final VoidCallback? onWritePressed;

  const DescriptorTile(
      {Key? key,
      required this.descriptor,
      this.onReadPressed,
      this.onWritePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Descriptor'),
          Text('0x${descriptor.uuid.toString().toUpperCase().substring(4, 8)}',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  ?.copyWith(color: Theme.of(context).textTheme.caption?.color))
        ],
      ),
      subtitle: StreamBuilder<List<int>>(
        stream: descriptor.value,
        initialData: descriptor.lastValue,
        builder: (c, snapshot) => Text(snapshot.data.toString()),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.file_download,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            onPressed: onReadPressed,
          ),
          IconButton(
            icon: Icon(
              Icons.file_upload,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            onPressed: onWritePressed,
          )
        ],
      ),
    );
  }
}
