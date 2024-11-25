import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gsatrancher/services/permission_service.dart';
import '../constants/ble_uuids.dart';
import '../models/device_advertising_data.dart';

/// BleService: A service for managing Bluetooth Low Energy (BLE) functionality.
///
/// This service performs the following main functions:
/// 1. Continuously scans for BLE devices.
/// 2. Filters devices based on specific service UUIDs (Nordic UART and DFU).
/// 3. Processes and stores scan results.
/// 4. Manages device connections and updates.
class BleService extends ChangeNotifier {
  // Dependencies
  final PermissionService _permissionService;
  
  // Scan state
  final Map<String, ScanResult> _devices = {};
  bool _isScanning = false;
  StreamSubscription? _scanSubscription;
  Timer? _scanTimer;
  bool _isEmulator = false;
  
  // Bluetooth and Location state
  bool _isBluetoothEnabled = false;
  bool _isLocationEnabled = false;
  
  // Stream controllers
  final _scanResultsController = StreamController<List<ScanResult>>.broadcast();
  final _scanningStateController = StreamController<bool>.broadcast();
  
  // Public getters
  Stream<List<ScanResult>> get scanResults => _scanResultsController.stream;
  Stream<bool> get isScanning => _scanningStateController.stream;
  bool get isBluetoothEnabled => _isBluetoothEnabled;
  bool get isLocationEnabled => _isLocationEnabled;

  BleService() : _permissionService = PermissionService() {
    _checkEmulator();
    _initializeStateMonitoring();
    _startPeriodicCheck();
  }

  void _initializeStateMonitoring() async {
    // Monitor Bluetooth state
    FlutterBluePlus.adapterState.listen((state) {
      _isBluetoothEnabled = state == BluetoothAdapterState.on;
      notifyListeners();
    });

    // Check initial states
    await _checkBluetoothState();
    await _checkLocationState();
  }

  Future<void> _checkBluetoothState() async {
    try {
      final state = await FlutterBluePlus.adapterState.first;
      _isBluetoothEnabled = state == BluetoothAdapterState.on;
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking Bluetooth state: $e');
    }
  }

  Future<void> _checkLocationState() async {
    try {
      _isLocationEnabled = await _permissionService.checkLocationEnabled();
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking location state: $e');
    }
  }

  void _startPeriodicCheck() {
    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _performPeriodicCheck();
    });
  }

  Future<void> _performPeriodicCheck() async {
    try {
      // Check Bluetooth state
      await _checkBluetoothState();
      
      // Check Location state
      await _checkLocationState();
      
      // Restart scan if needed
      if (_isScanning && _isBluetoothEnabled && _isLocationEnabled) {
        await _restartScan();
      }
    } catch (e) {
      debugPrint('Error in periodic check: $e');
    }
  }

  Future<void> startScan(BuildContext context) async {
    try {
      // Only start scanning if we're not already scanning
      if (!_isScanning) {
        debugPrint('🔍 Starting BLE scan...');
        
        // Clear existing devices
        _devices.clear();
        _scanResultsController.add([]);

        // Start scanning
        _isScanning = true;
        _scanningStateController.add(true);
        
        // Listen to scan results
        _scanSubscription?.cancel();
        _scanSubscription = FlutterBluePlus.scanResults.listen(
          (results) {
            debugPrint('📱 Found ${results.length} devices in scan');
            for (final result in results) {
              debugPrint('Device found: ${result.device.remoteId}, Name: ${result.device.localName}, RSSI: ${result.rssi}');
              debugPrint('Services: ${result.advertisementData.serviceUuids}');
              _handleScanResult(result);
            }
          },
          onError: (error) {
            debugPrint('❌ Error during scan: $error');
            stopScan();
          },
        );
        
        // Start periodic scanning
        _scanTimer?.cancel();
        _scanTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
          if (_isScanning) {
            debugPrint('🔄 Restarting periodic scan...');
            await FlutterBluePlus.startScan(
              timeout: const Duration(seconds: 4),
              androidUsesFineLocation: true,
              withServices: [
                Guid(BleUUIDs.NORDIC_UART_SERVICE_UUID),
                Guid(BleUUIDs.DEFAULT_DFU_SERVICE_UUID),
              ],
            );
          }
        });

        // Trigger initial scan
        debugPrint('🚀 Starting initial scan with service filters:');
        debugPrint('UART Service: ${BleUUIDs.NORDIC_UART_SERVICE_UUID}');
        debugPrint('DFU Service: ${BleUUIDs.DEFAULT_DFU_SERVICE_UUID}');
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 4),
          androidUsesFineLocation: true,
          withServices: [
            Guid(BleUUIDs.NORDIC_UART_SERVICE_UUID),
            Guid(BleUUIDs.DEFAULT_DFU_SERVICE_UUID),
          ],
        );
      }
    } catch (e) {
      debugPrint('❌ Error starting scan: $e');
      _isScanning = false;
      _scanningStateController.add(false);
    }
  }

  void _handleScanResult(ScanResult result) {
    try {
      // Store or update the device in our map
      _devices[result.device.remoteId.toString()] = result;
      
      // Notify listeners with the updated list
      final deviceList = _devices.values.toList();
      debugPrint('📝 Updated device list, total devices: ${deviceList.length}');
      _scanResultsController.add(deviceList);
    } catch (e) {
      debugPrint('❌ Error handling scan result: $e');
    }
  }

  Future<void> stopScan() async {
    _isScanning = false;
    _scanningStateController.add(false);
    _scanSubscription?.cancel();
    _scanTimer?.cancel();
    await FlutterBluePlus.stopScan();
  }

  Future<void> _restartScan() async {
    try {
      await FlutterBluePlus.stopScan();
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        androidUsesFineLocation: true,
        withServices: [
          Guid(BleUUIDs.NORDIC_UART_SERVICE_UUID),
          Guid(BleUUIDs.DEFAULT_DFU_SERVICE_UUID),
        ],
      );
    } catch (e) {
      debugPrint('Error restarting scan: $e');
    }
  }

  Future<void> connectToDevice(BluetoothDevice device, BuildContext context) async {
    try {
      await device.connect(
        timeout: const Duration(seconds: 30),
        autoConnect: false,
      );
      // TODO: Implement post-connection logic
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      rethrow;
    }
  }

  Future<void> _checkEmulator() async {
    if (!kIsWeb && Platform.isAndroid) {
      _isEmulator = await _permissionService.isEmulator();
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanTimer?.cancel();
    _scanResultsController.close();
    _scanningStateController.close();
    super.dispose();
  }
}
