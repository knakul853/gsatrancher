import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gsatrancher/services/permission_service.dart';
import '../constants/ble_uuids.dart';
import '../models/device_advertising_data.dart';

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
      String androidModel =
          const String.fromEnvironment('ANDROID_MODEL', defaultValue: '');
      _isEmulator = androidModel.toLowerCase().contains('sdk') ||
          androidModel.toLowerCase().contains('emulator');
    } else if (Platform.isIOS) {
      String iosModel = const String.fromEnvironment('SIMULATOR_DEVICE_NAME',
          defaultValue: '');
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
      bool permissionsGranted =
          await _permissionService.checkAndRequestPermissions(context);

      if (!permissionsGranted) {
        debugPrint('BLE permissions not granted');
        return;
      }

      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        debugPrint('Bluetooth not supported');
        return;
      }

      // Create scan filters for Nordic UART and DFU services
      List<Guid> serviceUuids = [
        Guid(BleUUIDs.NORDIC_UART_SERVICE_UUID),
        Guid(BleUUIDs.DEFAULT_DFU_SERVICE_UUID),
      ];

      // Start scanning with filters
      await FlutterBluePlus.startScan(
        withServices: serviceUuids,
        timeout: const Duration(seconds: 4),
        androidUsesFineLocation: true,
      );

      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          _handleScanResult(r);
        }
      }, onError: (e) {
        debugPrint('Error during BLE scan: $e');
        stopScan();
      });

      _isScanning = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting BLE scan: $e');
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

  DeviceAdvertisingData? getParsedManufacturingData(ScanResult scanResult) {
    final manufacturerData = scanResult.advertisementData.manufacturerData;
    if (manufacturerData.isEmpty) return null;

    // Check for manufacturer ID 0x576 (1398 in decimal)
    final data = manufacturerData[1398];
    if (data == null) return null;

    return DeviceAdvertisingData.fromManufacturerData(data);
  }

  void _handleScanResult(ScanResult r) {
    // Only add devices that haven't been discovered yet
    if (!_devices
        .any((device) => device.device.remoteId == r.device.remoteId)) {
      // Parse manufacturing data
      final manufacturingData = getParsedManufacturingData(r);
      if (manufacturingData != null) {
        _devices.add(r);
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    stopScan();
    super.dispose();
  }
}
