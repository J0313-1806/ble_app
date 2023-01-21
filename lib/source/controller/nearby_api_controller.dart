import 'dart:developer';
import 'dart:typed_data';
import 'package:ble_app/source/controller/chat_controller.dart';
import 'package:ble_app/source/controller/home_controller.dart';
import 'package:ble_app/source/model/device_model.dart';
import 'package:ble_app/source/view/widgets/modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nearby_connections/nearby_connections.dart';

class NearbyApiController extends GetxController {
  ///P2P_CLUSTER is a peer-to-peer strategy that supports an M-to-N,
  Strategy strategy = Strategy.P2P_CLUSTER;

  /// Here we do the Dependency Injection of various classes
  Nearby nearby = Get.put(Nearby());
  final HomeController _homeController = Get.find();
  final ChatController _chatController = Get.put(ChatController());

  /// Nickname of the logged in user
  RxString username = RxString("");

  /// Service ID of the device
  RxString serviceId = RxString("");

  /// List of devices detected
  RxList<DeviceModel> devices = RxList([]);

  /// The one who is requesting the info of a device
  RxString requestorId = RxString("");
  ConnectionInfo? requestorDeviceInfo;

  /// The one who starts the request with an info
  RxString requesteeId = RxString("");
  ConnectionInfo? requesteeDeviceInfo;

  @override
  void onInit() {
    // datesController.onInit();
    username = _homeController.hostName;
    advertiseDevice();
    searchNearbyDevices();
    super.onInit();
  }

  @override
  void onClose() {
    // datesController.onClose();
    // messagesController.connectedIdList.clear();
    nearby.stopAllEndpoints();
    nearby.stopDiscovery();
    nearby.stopAdvertising();
    super.onClose();
  }

  /// Discover nearby devices
  void searchNearbyDevices() async {
    try {
      await nearby.startDiscovery(
        username.value,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          this.serviceId(serviceId);

          /// Remove first the device from the list in case it was already there
          /// This duplication could occur since we combine advertise and discover
          devices.removeWhere((device) => device.id == id);

          /// Once an endpoint is found, add it
          /// to the end of the devices observable
          devices.add(DeviceModel(
              id: id, name: name, serviceId: serviceId, isConnected: false));
        },
        onEndpointLost: (id) {
          _chatController.onDisconnect(id ?? "");
          devices.removeWhere((device) => device.id == id);
          nearby.disconnectFromEndpoint(id ?? "");
        },
        serviceId: "com.example.ble_app",
      );
    } catch (e) {
      log('there is an error searching for nearby devices:: $e');
    }
  }

  /// Advertise own device to other devices nearby
  RxString phoneId = RxString("");
  ConnectionInfo? advertisersInfo;
  void advertiseDevice() async {
    try {
      await nearby.startAdvertising(
        username.value,
        strategy,
        onConnectionInitiated: (id, info) {
          /// Remove first the device from the list in case it was already there
          /// This duplication could occur since we combine advertise and discover
          devices.removeWhere((device) => device.id == id);

          /// We are about to use this info once we add the device to the device list
          requestorDeviceInfo = info;
          phoneId(id);
          advertisersInfo = info;

          /// show the bottom modal widget
          Get.bottomSheet(
            const ModelSheet(),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          );
        },
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            _chatController.onConnect(id);

            /// Add to device list
            devices.add(DeviceModel(
                id: id,
                name: requestorDeviceInfo!.endpointName,
                serviceId: requestorDeviceInfo!.endpointName,
                isConnected: true));
          } else if (status == Status.REJECTED) {
            /// Add to device list
            devices.add(DeviceModel(
                id: id,
                name: requestorDeviceInfo!.endpointName,
                serviceId: requestorDeviceInfo!.endpointName,
                isConnected: false));
          }
        },
        onDisconnected: (endpointId) {
          _chatController.onDisconnect(endpointId);

          /// Remove the device from the device list
          devices.removeWhere((device) => device.id == endpointId);
        },
      );
    } catch (e) {
      log('there is an error advertising the device:: $e');
    }
  }

  RxBool requestLoader = RxBool(false);

  /// Request to connect to other devices
  void requestDevice({
    required String deviceId,
    required void Function(String endpointId, Status status) onConnectionResult,
    required void Function(String endpointId) onDisconnected,
  }) async {
    requestLoader(true);
    try {
      await nearby.requestConnection(
        username.value,
        deviceId,
        onConnectionInitiated: (id, info) {
          requestLoader(false);

          /// We are about to use this info once we add the device to the device list
          requesteeDeviceInfo = info;

          /// show the bottom modal widget
          Get.bottomSheet(const ModelSheet()); //!deviceId, id, info
        },
        onConnectionResult: onConnectionResult,
        onDisconnected: (value) {
          _chatController.onDisconnect(deviceId);
          onDisconnected(value);
        },
      );
    } catch (e) {
      log('there is an error requesting to connect to a device:: $e');
    }
  }

  /// Disconnect from another device
  void disconnectDevice(
      {required String id, required void Function() updateStateFunction}) {
    try {
      _chatController.onDisconnect(id);
      nearby.disconnectFromEndpoint(id);
      updateStateFunction();
    } catch (e) {
      log('there is an error disconnecting the device:: $e');
    }
  }

  /// Reject request to connect to another device
  void rejectConnection({required String id}) async {
    try {
      _chatController.onDisconnect(id);
      await nearby.rejectConnection(id);
    } catch (e) {
      log('there is an error in rejection:: $e');
    }
  }

  /// Accept request to connect to another device
  void acceptConnection(
      {required String id, required ConnectionInfo info}) async {
    try {
      _chatController.onConnect(id);
      nearby.acceptConnection(
        id,
        onPayLoadRecieved: (endId, payload) {
          _chatController.onReceiveMessage(
            fromId: endId,
            fromInfo: info,
            payload: payload,
          );
        },
      );
    } catch (e) {
      log('there is an error accepting connection from another device:: $e');
    }
  }

  /// Send message to another device
  Future<bool> sendMessage(
      {required String toId,
      required String toUsername,
      required String fromId,
      required String fromUsername,
      required String message}) async {
    try {
      if (_chatController.isDeviceConnected(toId)) {
        nearby.sendBytesPayload(toId, Uint8List.fromList(message.codeUnits));
        _chatController.onSendMessage(
            toId: toId,
            toUsername: toUsername,
            fromId: fromId,
            fromUsername: fromUsername,
            message: message);
        return true;
      }
      return false;
    } catch (e) {
      log('there is an error sending message to another device:: $e');
      return false;
    }
  }
}
