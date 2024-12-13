class Device {
  final String id;
  final String name;
  final bool isConnected;
  final String status;
  final String firmwareVersion;
  final int batteryLevel;
  final String signalStrength;

  Device({
    required this.id,
    required this.name,
    required this.isConnected,
    required this.status,
    required this.firmwareVersion,
    required this.batteryLevel,
    required this.signalStrength,
  });

  String get version => firmwareVersion;
}
