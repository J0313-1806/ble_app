import 'package:ble_app/source/controller/chat_controller.dart';
import 'package:ble_app/source/controller/home_controller.dart';
import 'package:ble_app/source/controller/nearby_api_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModelSheet extends StatelessWidget {
  const ModelSheet({super.key});
  static final NearbyApiController _nearbyApiController = Get.find();
  static final ChatController _chatController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(_nearbyApiController.requestorId.value),
              const SizedBox(width: 10),
              Text(_nearbyApiController.phoneId.value)
            ],
          ),
          Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _nearbyApiController.acceptConnection(
                    id: _nearbyApiController.phoneId.value,
                    info: _nearbyApiController.connectionInfo!),
                child: const Text("accept"),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () => _nearbyApiController.rejectConnection(
                    id: _nearbyApiController.phoneId.value),
                child: const Text("reject"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
