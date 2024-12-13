import 'package:flutter/foundation.dart';
import '../models/device_model.dart';

class DeviceService extends ChangeNotifier {
  bool _isConnected = false;
  bool _isBluetoothEnabled = false;
  bool _isLocationEnabled = false;
  Device? _currentDevice;

  bool get isConnected => _isConnected;
  bool get isBluetoothEnabled => _isBluetoothEnabled;
  bool get isLocationEnabled => _isLocationEnabled;
  Device? get currentDevice => _currentDevice;

  void setConnectedDevice(Device device) {
    _currentDevice = device;
    _isConnected = true;
    notifyListeners();
  }

  Future<void> connectToDevice(String deviceId, String name, String version) async {
    _currentDevice = Device(
      id: deviceId,
      name: name,
      isConnected: true,
      status: 'Connected',
      firmwareVersion: version,
      batteryLevel: 75, // TODO: Get actual battery level
      signalStrength: 'STRONG', // TODO: Calculate from RSSI
    );
    _isConnected = true;
    notifyListeners();
  }

  Future<void> disconnectDevice() async {
    _isConnected = false;
    _currentDevice = null;
    notifyListeners();
  }

  void updateBluetoothStatus(bool isEnabled) {
    _isBluetoothEnabled = isEnabled;
    notifyListeners();
  }

  void updateLocationStatus(bool isEnabled) {
    _isLocationEnabled = isEnabled;
    notifyListeners();
  }
}
