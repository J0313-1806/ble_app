import 'package:ble_app/source/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceServices extends StatelessWidget {
  const DeviceServices({super.key});

  static final HomeController _homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: Text(_homeController.deviceId.value),
          ),
      body: ListView.builder(
          itemCount: 0, // _homeController.serviceList.length,
          itemBuilder: (context, index) {
            // var service = _homeController.serviceList[index];
            // var characteristics = service.characteristics;
            return ExpansionTile(
              title: Text("service.serviceId.toString()"),
              // children: List.generate(
              //     characteristics.length,
              //     (index) => Container(
              //           child: Row(
              //             children: [
              //               Column(
              //                 children: const [
              //                   Text("charecteristic ID"),
              //                   Text("is isdicatable"),
              //                   Text("is notifiable"),
              //                   Text("is readble"),
              //                   Text("is writable without response"),
              //                 ],
              //               ),
              //               const SizedBox(
              //                 width: 10,
              //               ),
              //               Column(
              //                 children: [
              //                   Text(characteristics[index]
              //                       .characteristicId
              //                       .toString()),
              //                   Text(characteristics[index]
              //                       .isIndicatable
              //                       .toString()),
              //                   Text(characteristics[index]
              //                       .isNotifiable
              //                       .toString()),
              //                   Text(characteristics[index]
              //                       .isReadable
              //                       .toString()),
              //                   Text(characteristics[index]
              //                       .isWritableWithoutResponse
              //                       .toString()),
              //                 ],
              //               ),
              //             ],
              //           ),
              //         )),
            );
          }),
    );
  }
}
