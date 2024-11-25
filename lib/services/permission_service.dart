import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:location/location.dart' as location;

class PermissionService extends ChangeNotifier {
  final location.Location _location = location.Location();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<bool> checkAndRequestPermissions(BuildContext context) async {
    try {
      // First check if Bluetooth is turned on
      if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
        // Wait for Bluetooth to be turned on
        await FlutterBluePlus.turnOn();
      }

      List<Permission> permissions = [];
      
      if (Platform.isAndroid) {
        permissions = [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.bluetoothAdvertise,
          Permission.location,
        ];
      } else if (Platform.isIOS) {
        permissions = [
          Permission.bluetooth,
          Permission.location,
        ];
      }

      // Check which permissions are not granted
      List<Permission> notGrantedPermissions = [];
      for (Permission permission in permissions) {
        PermissionStatus status = await permission.status;
        if (!status.isGranted) {
          notGrantedPermissions.add(permission);
        }
      }

      // Only request permissions that are not granted
      if (notGrantedPermissions.isNotEmpty) {
        // Show permission dialog for all needed permissions at once
        bool shouldContinue = await _showPermissionDialog(context, notGrantedPermissions);
        if (!shouldContinue) return false;

        // Request all needed permissions
        Map<Permission, PermissionStatus> statuses = await notGrantedPermissions.request();
        
        // Check if all permissions were granted
        bool allGranted = statuses.values.every((status) => status.isGranted);
        if (!allGranted) {
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  Future<bool> checkLocationEnabled() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          return false;
        }
      }

      location.PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == location.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != location.PermissionStatus.granted) {
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error checking location status: $e');
      return false;
    }
  }

  Future<bool> isEmulator() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.isPhysicalDevice == false;
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return !iosInfo.isPhysicalDevice;
    }
    return false;
  }

  Future<bool> _showBluetoothDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth Required'),
        content: const Text('Please enable Bluetooth to scan for devices.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Enable Bluetooth'),
          ),
        ],
      ),
    ) ?? false;
  }

  String _getPermissionText(Permission permission) {
    switch (permission) {
      case Permission.bluetooth:
        return 'Bluetooth';
      case Permission.bluetoothScan:
        return 'Bluetooth Scanning';
      case Permission.bluetoothConnect:
        return 'Bluetooth Connection';
      case Permission.bluetoothAdvertise:
        return 'Bluetooth Advertising';
      case Permission.location:
        return 'Location';
      default:
        return permission.toString();
    }
  }

  Future<bool> _showPermissionDialog(BuildContext context, List<Permission> deniedPermissions) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(
              Icons.security,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Permissions Required',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This app needs the following permissions to scan for and connect to devices:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...deniedPermissions.map((permission) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _getPermissionText(permission),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    ) ?? false;
  }
}
