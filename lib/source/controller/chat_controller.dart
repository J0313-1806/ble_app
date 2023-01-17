import 'package:ble_app/source/model/chat_model.dart';
import 'package:get/get.dart';
import 'package:nearby_connections/nearby_connections.dart';

class ChatController extends GetxController {
  RxList<ChatModel> messages = RxList([]);
  var username = ''.obs;
  RxList<String> connectedDevices = RxList([]);

  @override
  void onInit() {
    super.onInit();
    // username = RxString(loginController.username.value);
  }

  @override
  void onClose() {
    messages.clear();
    super.onClose();
  }

  /// return true if the device id is included in the list of connected devices
  bool isDeviceConnected(String id) =>
      connectedDevices.contains(id) ? true : false;

  /// add the device id to the list of connected devices
  void onConnect(String id) => connectedDevices.add(id);

  /// remove the device id from the list of connected devices
  void onDisconnect(String id) =>
      connectedDevices.removeWhere((element) => element == id);

  void onSendMessage(
      {required String toId,
      required String toUsername,
      required String fromId,
      required String fromUsername,
      required String message}) {
    /// Add the message object received to the messages list
    messages.add(ChatModel(
      sent: true,
      toId: toId,
      fromId: fromId,
      toUsername: toUsername,
      fromUsername: fromUsername,
      message: message,
      dateTime: DateTime.now(),
    ));

    /// This will force a widget rebuild
    update();
  }

  void onReceiveMessage(
      {required String fromId,
      required Payload payload,
      required ConnectionInfo fromInfo}) async {
    /// Once receive a payload in the form of Bytes,
    if (payload.type == PayloadType.BYTES) {
      /// we will convert the bytes into String
      String messageString = String.fromCharCodes(payload.bytes ?? []);

      /// Add the message object to the messages list
      messages.add(
        ChatModel(
          sent: false,
          fromId: fromId,
          toId: "",
          fromUsername: fromInfo.endpointName,
          toUsername: username.value,
          message: messageString,
          dateTime: DateTime.now(),
        ),
      );
    }

    update();
  }
}
