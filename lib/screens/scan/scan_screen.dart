import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import '../../constants/app_colors.dart';
import '../../widgets/status_indicators.dart';
import '../../services/ble_service.dart';
import '../../widgets/device_list_item.dart';
import '../../models/device_advertising_data.dart';
import '../../services/permission_service.dart';
import '../../services/device_service.dart'; // Added import for DeviceService

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late BleService _bleService;
  late PermissionService _permissionService;
  bool _hasCheckedPermissions = false;
  int selectedDevicesCount = 0;
  final _location = loc.Location();
  String _connectionStatus = '';

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 Initializing ScanScreen...');
    _bleService = context.read<BleService>();
    _permissionService = context.read<PermissionService>();

    // Listen to connection state changes
    _bleService.connectionState.listen((status) {
      setState(() => _connectionStatus = status);
      if (status == 'Connected') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device connected successfully!')),
        );
      } else if (status == 'Connection failed' || status == 'Connection timeout') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to connect to device'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        debugPrint('🔍 Checking permissions before scan...');
        // Check if we already have permissions
        bool hasPermissions = await _checkPermissions();
        debugPrint('📱 Has permissions: $hasPermissions');
        if (hasPermissions && mounted) {
          debugPrint('✅ Starting scan...');
          _bleService.startScan(context);
        } else {
          debugPrint('❌ Cannot start scan, missing permissions');
        }
      }
    });
  }

  Future<bool> _checkPermissions() async {
    if (_hasCheckedPermissions) return true;

    debugPrint('🔐 Checking permissions...');

    if (Platform.isIOS) {
      debugPrint('📱 iOS: Checking location services...');
      
      // Check if location service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      debugPrint('📍 Location service enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        // Request to enable location service
        serviceEnabled = await _location.requestService();
        debugPrint('📍 Location service after request: $serviceEnabled');
        if (!serviceEnabled) {
          debugPrint('❌ Location services not enabled');
          return false;
        }
      }

      // Check location permission
      var permissionStatus = await _location.hasPermission();
      debugPrint('📍 Location permission status: $permissionStatus');
      
      if (permissionStatus == loc.PermissionStatus.denied) {
        // Request permission
        permissionStatus = await _location.requestPermission();
        debugPrint('📍 Location permission after request: $permissionStatus');
        if (permissionStatus != loc.PermissionStatus.granted) {
          debugPrint('❌ Location permission not granted');
          return false;
        }
      }

      debugPrint('✅ Location services and permissions granted on iOS');
      _hasCheckedPermissions = true;
      return true;
    } else {
      // Android permission handling
      List<Permission> permissions = [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.location,
      ];

      // Check if all permissions are already granted
      bool allGranted = true;
      for (var permission in permissions) {
        final status = await permission.status;
        debugPrint('📱 Permission ${permission.toString()}: ${status.toString()}');
        
        if (!status.isGranted) {
          debugPrint('❌ Permission ${permission.toString()} not granted');
          allGranted = false;
          
          // Request the permission
          final result = await permission.request();
          debugPrint('🔄 Requested ${permission.toString()}: ${result.toString()}');
          if (!result.isGranted) {
            return false;
          }
        }
      }

      _hasCheckedPermissions = allGranted;
      debugPrint('✅ All permissions granted: $allGranted');
      return allGranted;
    }
  }

  @override
  void dispose() {
    _bleService.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BleService>(
      builder: (context, bleService, child) {
        return WillPopScope(
          onWillPop: () async {
            await bleService.stopScan();
            return true;
          },
          child: Scaffold(
            backgroundColor: AppColors.lightBackdrop,
            body: Column(
              children: [
                // Top Navigation Bar
                Container(
                  color: AppColors.primary600,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            color: Colors.white,
                            onPressed: () async {
                              await bleService.stopScan();
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                          Row(
                            children: [
                              StatusIndicators(
                                isBluetoothEnabled:
                                    bleService.isBluetoothEnabled,
                                isLocationEnabled: bleService.isLocationEnabled,
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Connect Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            children: [
                              Icon(
                                Icons.bluetooth_searching,
                                size: 30,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Connect',
                                style: TextStyle(
                                  fontSize: 26,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Update Devices Card
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 25,
                            right: 25,
                            top: 15,
                          ),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.primary600.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.bluetooth,
                                      size: 24,
                                      color: AppColors.primary600,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Begin Update',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '$selectedDevicesCount Device Selected',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.lightMidGray,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 25,
                            right: 25,
                            top: 15,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.qr_code_scanner,
                                  onTap: () {
                                    // TODO: Implement QR scanning
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.filter_list,
                                  onTap: () {
                                    // TODO: Implement filtering
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 25,
                            right: 25,
                            top: 15,
                            bottom: 5,
                          ),
                          child: Container(
                            height: 2,
                            color: AppColors.lightDivider,
                          ),
                        ),

                        // Device List
                        _buildDeviceList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceList() {
    return StreamBuilder<List<ScanResult>>(
      stream: _bleService.scanResults,
      builder: (context, snapshot) {
        debugPrint('StreamBuilder snapshot: ${snapshot.hasData}');
        if (snapshot.hasData) {
          final devices = snapshot.data!;
          return ListView.builder(
            key: const ValueKey('deviceList'), // Added key for rebuild
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 10,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final scanResult = devices[index];
              final device = scanResult.device;
              final advertisingData = DeviceAdvertisingData.fromScanResult(scanResult);
              // Convert RSSI (-100 to -30 dBm) to percentage (0-100%)
              final signalStrength = ((scanResult.rssi + 100) ~/ 1.25).clamp(0, 100);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DeviceListItem(
                  deviceName: advertisingData.deviceName,
                  version: advertisingData.version?.formattedVersion ?? 'Unknown',
                  batteryLevel: advertisingData.stateOfCharge ?? 0,
                  signalStrength: signalStrength,
                  hasUpdate: false, // TODO: Implement update check
                  onTap: () => _connectToDevice(device),
                ),
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    // Show connecting dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Connecting to ${device.localName}...'),
          ],
        ),
      ),
    );

    // Stop scanning before connecting
    await _bleService.stopScan();
    
    // Attempt connection
    final success = await _bleService.connectToDevice(device, context);
    
    if (mounted) {
      Navigator.of(context).pop(); // Dismiss the dialog
      
      if (success) {
        // Update device service with connected device
        final deviceService = context.read<DeviceService>();
        await deviceService.connectToDevice(
          device.remoteId.toString(),
          device.localName ?? 'Unknown Device',
          'v2.2.3', // TODO: Get actual version from device
        );
        
        // Navigate back to home screen
        Navigator.of(context).pop();
      } else {
        // Restart scanning if connection failed
        _bleService.startScan(context);
      }
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 30,
            color: AppColors.primary600,
          ),
        ),
      ),
    );
  }
}
