class Version {
  final int major;
  final int minor;
  final int patch;

  Version({
    this.major = 0,
    this.minor = 0,
    this.patch = 0,
  });

  String get formattedVersion => '$major.$minor.$patch';

  factory Version.fromString(String version) {
    final parts = version.split('.');
    return Version(
      major: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
      minor: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      patch: parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
    );
  }
}

class DeviceAdvertisingData {
  final Version? version;
  final double? voltage;
  final int? stateOfCharge;
  final int? configVersion;

  DeviceAdvertisingData({
    this.version,
    this.voltage,
    this.stateOfCharge,
    this.configVersion,
  });

  factory DeviceAdvertisingData.fromManufacturerData(List<int>? data) {
    if (data == null || data.isEmpty) return DeviceAdvertisingData();

    Version? version;
    double? voltage;
    int? stateOfCharge;
    int? configVersion;

    // Parse version (first 3 bytes)
    if (data.length > 2) {
      final major = data[0] & 0xFF;
      final minor = data[1] & 0xFF;
      final patch = data[2] & 0xFF;
      version = Version(major: major, minor: minor, patch: patch);
    }

    // Parse voltage (bytes 3-4)
    if (data.length >= 5) {
      final voltageData = data.sublist(3, 5);
      final voltReading = (voltageData[0] | (voltageData[1] << 8));
      voltage = (voltReading * 0.078) / 1000;
    }

    // Parse state of charge and config version (bytes 5-7)
    if (data.length >= 8) {
      stateOfCharge = data[5];
      final configVersion1 = data[6];
      final configVersion2 = data[7];
      configVersion = int.parse('$configVersion1$configVersion2', radix: 16);
    }

    return DeviceAdvertisingData(
      version: version,
      voltage: voltage,
      stateOfCharge: stateOfCharge,
      configVersion: configVersion,
    );
  }
}
