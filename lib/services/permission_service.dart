import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService extends ChangeNotifier {
  Future<bool> checkAndRequestPermissions(BuildContext context) async {
    List<Permission> permissions = [];
    
    if (Platform.isAndroid) {
      permissions = [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ];
    } else if (Platform.isIOS) {
      permissions = [
        Permission.bluetooth,
        Permission.location,
      ];
    }

    // Check current permission status
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    bool allGranted = true;
    List<Permission> deniedPermissions = [];
    
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
        deniedPermissions.add(permission);
      }
    });

    if (!allGranted) {
      return await _showPermissionDialog(context, deniedPermissions);
    }

    return true;
  }

  String _getPermissionText(Permission permission) {
    switch (permission) {
      case Permission.bluetooth:
        return 'Bluetooth';
      case Permission.bluetoothScan:
        return 'Bluetooth Scanning';
      case Permission.bluetoothConnect:
        return 'Bluetooth Connection';
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
            Icon(
              Icons.bluetooth_searching,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Permission Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To scan for nearby devices, we need:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...deniedPermissions.map((permission) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    _getPermissionText(permission),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
            const Text(
              'These permissions are essential for the app to function properly.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Not Now',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    ) ?? false;
  }
}
