import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gsatrancher/services/permission_service.dart';

class BleService extends ChangeNotifier {
  final List<ScanResult> _devices = [];
  bool _isScanning = false;
  StreamSubscription? _scanSubscription;
  bool _isEmulator = false;
  final PermissionService _permissionService = PermissionService();

  BleService() {
    _checkEmulator();
  }

  void _checkEmulator() {
    // Check if running on emulator
    if (Platform.isAndroid) {
      String androidModel = const String.fromEnvironment('ANDROID_MODEL', defaultValue: '');
      _isEmulator = androidModel.toLowerCase().contains('sdk') ||
                    androidModel.toLowerCase().contains('emulator');
    } else if (Platform.isIOS) {
      String iosModel = const String.fromEnvironment('SIMULATOR_DEVICE_NAME', defaultValue: '');
      _isEmulator = iosModel.isNotEmpty;
    }
  }

  List<ScanResult> get devices => _devices;
  bool get isScanning => _isScanning;

  Future<void> startScan(BuildContext context) async {
    if (_isScanning) return;

    // Clear previous results
    _devices.clear();
    
    try {
      // If running in emulator, simulate devices for testing
      if (_isEmulator) {
        _simulateDevices();
        return;
      }

      // Check permissions first
      bool permissionsGranted = await _permissionService.checkAndRequestPermissions(context);
      
      if (!permissionsGranted) {
        debugPrint('BLE permissions not granted');
        return;
      }

      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        debugPrint('Bluetooth not supported');
        return;
      }

      // Check if Bluetooth is on
      if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
        debugPrint('Bluetooth is turned off');
        return;
      }

      // Start scanning
      debugPrint('Starting BLE scan...');
      _isScanning = true;
      notifyListeners();

      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          for (ScanResult result in results) {
            if (!_devices.contains(result)) {
              _devices.add(result);
              debugPrint('Found device: ${result.device.remoteId}');
              notifyListeners();
            }
          }
        },
        onError: (error) {
          debugPrint('Error during scan: $error');
          stopScan();
        },
      );

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      debugPrint('Error starting scan: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  void _simulateDevices() {
    debugPrint('Running in emulator, simulating devices...');
    _isScanning = true;
    notifyListeners();

    // Simulate finding devices over time
    Timer(const Duration(seconds: 1), () {
      _addSimulatedDevice('GSA Device 1', -65);
    });

    Timer(const Duration(seconds: 2), () {
      _addSimulatedDevice('GSA Device 2', -72);
    });

    Timer(const Duration(seconds: 3), () {
      _addSimulatedDevice('GSA Device 3', -58);
      _isScanning = false;
      notifyListeners();
    });
  }

  void _addSimulatedDevice(String name, int rssi) {
    final deviceId = name.replaceAll(' ', '_').toLowerCase();
    
    final advData = AdvertisementData(
      advName: name,
      txPowerLevel: -59,
      connectable: true,
      manufacturerData: {},
      serviceData: {},
      serviceUuids: [],
      appearance: 0,
    );

    final result = ScanResult(
      device: BluetoothDevice.fromId(deviceId),
      rssi: rssi,
      timeStamp: DateTime.now(),
      advertisementData: advData,
    );

    _devices.add(result);
    notifyListeners();
  }

  Future<void> stopScan() async {
    if (!_isScanning) return;

    try {
      debugPrint('Stopping BLE scan...');
      if (!_isEmulator) {
        await FlutterBluePlus.stopScan();
      }
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      _isScanning = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    }
  }

  Future<bool> isBluetoothOn() async {
    if (_isEmulator) return true;
    
    try {
      final state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      debugPrint('Error checking Bluetooth state: $e');
      return false;
    }
  }

  @override
  void dispose() {
    stopScan();
    super.dispose();
  }
}
