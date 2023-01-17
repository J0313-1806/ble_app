class DeviceModel {
  final String id;
  final String name;
  final String serviceId;
  final bool isConnected;

  DeviceModel(
      {required this.id,
      required this.name,
      required this.serviceId,
      required this.isConnected});
}
