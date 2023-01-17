import 'package:ble_app/source/constants/colors.dart';
import 'package:ble_app/source/controller/nearby_api_controller.dart';
import 'package:ble_app/source/controller/home_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  // static final ChatController _chatController = Get.put(ChatController());
  static final HomeController _homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NearbyApiController>(
        init: NearbyApiController(),
        initState: (state) {
          state.controller;
        },
        builder: (chatController) {
          return Scaffold(
            appBar: AppBar(
              title: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    // Text(chatController.user.id),
                    const SizedBox(width: 10),
                    // _homeController.devices.values.elementAt(Get.arguments)
                    //     ? Container(
                    //         padding: const EdgeInsets.all(5.0),
                    //         decoration: const BoxDecoration(
                    //             shape: BoxShape.circle,
                    //             color: ColorConstants.green),
                    //       )
                    //     : const Center(),
                  ],
                ),
              ),
              backgroundColor: ColorConstants.black,
            ),
            body: ListView(),
          );
        });
  }
}
