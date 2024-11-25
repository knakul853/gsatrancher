import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
  final String deviceName;

  DeviceAdvertisingData({
    this.version,
    this.voltage,
    this.stateOfCharge,
    this.configVersion,
    required this.deviceName,
  });

  factory DeviceAdvertisingData.fromManufacturerData(List<int>? data, {required String deviceName}) {
    if (data == null || data.isEmpty) return DeviceAdvertisingData(deviceName: deviceName);

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

    // Parse voltage (next 2 bytes)
    if (data.length > 4) {
      final voltageRaw = ((data[3] & 0xFF) << 8) | (data[4] & 0xFF);
      voltage = voltageRaw / 1000.0; // Convert millivolts to volts
    }

    // Parse state of charge (next byte)
    if (data.length > 5) {
      stateOfCharge = data[5] & 0xFF;
    }

    // Parse config version (next byte)
    if (data.length > 6) {
      configVersion = data[6] & 0xFF;
    }

    return DeviceAdvertisingData(
      version: version,
      voltage: voltage,
      stateOfCharge: stateOfCharge,
      configVersion: configVersion,
      deviceName: deviceName,
    );
  }

  factory DeviceAdvertisingData.fromScanResult(ScanResult result) {
    final manufacturerData = result.advertisementData.manufacturerData;
    final deviceName = result.device.platformName.isNotEmpty 
        ? result.device.platformName 
        : result.advertisementData.localName.isNotEmpty
            ? result.advertisementData.localName
            : 'Unknown Device';

    // Check for manufacturer ID 0x576 (1398 in decimal)
    final data = manufacturerData[1398];
    
    return DeviceAdvertisingData.fromManufacturerData(
      data,
      deviceName: deviceName,
    );
  }
}
