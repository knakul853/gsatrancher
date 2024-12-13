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
  Timer? _scanTimer; // Timer for periodic updates
  Timer? _uiUpdateTimer; // Timer for UI updates
  Timer? _deviceRemovalTimer; // Timer for removing disconnected devices
  bool _isEmulator = false;

  // Bluetooth and Location state
  bool _isBluetoothEnabled = false;
  bool _isLocationEnabled = false;

  // Stream controllers
  final _scanResultsController = StreamController<List<ScanResult>>.broadcast();
  final _scanningStateController = StreamController<bool>.broadcast();

  // Device timeout duration
  static const deviceTimeoutDuration = Duration(seconds: 7);
  
  // Device state tracking
  final Map<String, DateTime> _lastSeenDevices = {};
  StreamController<String>? _connectionStateController;

  // Public getters
  Stream<List<ScanResult>> get scanResults => _scanResultsController.stream;
  Stream<bool> get isScanning => _scanningStateController.stream;
  bool get isBluetoothEnabled => _isBluetoothEnabled;
  bool get isLocationEnabled => _isLocationEnabled;
  Stream<String> get connectionState => _connectionStateController!.stream;

  BleService() : _permissionService = PermissionService() {
    _connectionStateController = StreamController<String>.broadcast();
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
        // Start UI update timer
        _startUIUpdateTimer();
        _startDeviceRemovalTimer(); // Start device removal timer
      }
    } catch (e) {
      debugPrint('❌ Error starting scan: $e');
      _isScanning = false;
      _scanningStateController.add(false);
    }
  }

  void _handleScanResult(ScanResult result) {
    try {
      final deviceId = result.device.remoteId.toString();
      
      // Update last seen time for the device
      _lastSeenDevices[deviceId] = DateTime.now();
      
      // Store or update the device in our map
      _devices[deviceId] = result;

      // Notify listeners with the updated list
      _updateDeviceList();
      
      debugPrint('📱 Updated device: ${result.device.localName} (${result.rssi} dBm)');
    } catch (e) {
      debugPrint('❌ Error handling scan result: $e');
    }
  }

  void _updateDeviceList() {
    final now = DateTime.now();
    
    // Remove timed out devices
    _lastSeenDevices.removeWhere((deviceId, lastSeen) {
      final hasTimedOut = now.difference(lastSeen) > deviceTimeoutDuration;
      if (hasTimedOut) {
        _devices.remove(deviceId);
        debugPrint('🗑️ Removed timed out device: $deviceId');
      }
      return hasTimedOut;
    });

    // Notify listeners with the updated list
    final deviceList = _devices.values.toList();
    debugPrint('📝 Device list updated, active devices: ${deviceList.length}');
    _scanResultsController.add(deviceList);
  }

  Future<void> stopScan() async {
    _isScanning = false;
    _scanningStateController.add(false);
    _scanSubscription?.cancel();
    _scanTimer?.cancel();
    _uiUpdateTimer?.cancel(); // Cancel UI update timer
    _deviceRemovalTimer?.cancel(); // Cancel device removal timer
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

  Future<bool> connectToDevice(BluetoothDevice device, BuildContext context) async {
    try {
      _connectionStateController?.add('Connecting to ${device.localName}...');
      debugPrint('🔌 Attempting to connect to device: ${device.localName}');

      // Set up connection timeout
      bool hasConnected = false;
      Timer? timeoutTimer;
      
      timeoutTimer = Timer(const Duration(seconds: 10), () {
        if (!hasConnected) {
          debugPrint('⏰ Connection timeout for device: ${device.localName}');
          _connectionStateController?.add('Connection timeout');
          device.disconnect();
        }
      });

      // Attempt connection
      await device.connect(
        timeout: const Duration(seconds: 10),
        autoConnect: false,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection attempt timed out');
        },
      );

      hasConnected = true;
      timeoutTimer.cancel();
      
      debugPrint('✅ Successfully connected to: ${device.localName}');
      _connectionStateController?.add('Connected');
      return true;

    } catch (e) {
      debugPrint('❌ Connection error: $e');
      _connectionStateController?.add('Connection failed');
      return false;
    }
  }

  void _checkEmulator() async {
    if (!kIsWeb && Platform.isAndroid) {
      _isEmulator = await _permissionService.isEmulator();
    }
  }

  void _startUIUpdateTimer() {
    // Start a timer to emit UI updates every 5 seconds
    _uiUpdateTimer?.cancel();
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      debugPrint('⏰ Triggering UI update...');
      notifyListeners(); // Notify listeners to rebuild UI
    });
  }

  void _startDeviceRemovalTimer() {
    _deviceRemovalTimer?.cancel();
    _deviceRemovalTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _removeDisconnectedDevices();
    });
  }

  void _removeDisconnectedDevices() {
    // Create a copy to avoid ConcurrentModificationException
    final devicesToRemove = _devices.keys.toList();
    for (final deviceId in devicesToRemove) {
      if (!_devices.containsKey(deviceId)) continue;
      final result = _devices[deviceId]!;
      if (result.rssi == 0) { // Assuming RSSI of 0 means disconnected
        _devices.remove(deviceId);
        debugPrint('Removed device: $deviceId');
        _scanResultsController.add(_devices.values.toList());
      }
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanTimer?.cancel();
    _uiUpdateTimer?.cancel();
    _deviceRemovalTimer?.cancel();
    _scanResultsController.close();
    _scanningStateController.close();
    _connectionStateController?.close();
    super.dispose();
  }
}
