class Device {
  final String id;
  final String name;
  final bool isConnected;
  final String status;
  final String firmwareVersion;

  Device({
    required this.id,
    required this.name,
    required this.isConnected,
    required this.status,
    required this.firmwareVersion,
  });
}
