import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/device_card.dart';
import '../../widgets/status_indicators.dart';
import '../../services/device_service.dart';
import 'package:provider/provider.dart';
import '../scan/scan_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceService>(
      builder: (context, deviceService, child) {
        final bool isConnected = deviceService.isConnected;
        final device = deviceService.currentDevice;

        return Scaffold(
          backgroundColor: AppColors.lightBackdrop,
          body: Column(
            children: [
              // Top Navigation Bar with Status Indicators
              Container(
                color: AppColors.primary600,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        StatusIndicators(
                          isBluetoothEnabled: deviceService.isBluetoothEnabled,
                          isLocationEnabled: deviceService.isLocationEnabled,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Device Status Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isConnected ? 'CONNECTED' : 'DISCONNECTED',
                              style: TextStyle(
                                fontSize: 24,
                                color: isConnected ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isConnected)
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => deviceService.disconnectDevice(),
                              ),
                          ],
                        ),
                        if (isConnected && device != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    device.version,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.battery_full),
                                      Text('${device.batteryLevel}%'),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    children: [
                                      const Icon(Icons.signal_cellular_4_bar),
                                      Text(device.signalStrength),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ] else ...[
                          const Text(
                            'No Device',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.battery_unknown, color: Colors.grey),
                              SizedBox(width: 16),
                              Icon(Icons.wifi_off, color: Colors.grey),
                              SizedBox(width: 16),
                              Icon(Icons.signal_cellular_0_bar, color: Colors.grey),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      if (!isConnected) ...[
                        _ActionButton(
                          icon: Icons.phone_android,
                          title: 'Connect to Device',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ScanScreen()),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ActionButton(
                          icon: Icons.code,
                          title: 'Update Devices',
                          onTap: () {}, // TODO: Implement update devices
                        ),
                        const SizedBox(height: 16),
                        _ActionButton(
                          icon: Icons.flash_on,
                          title: 'Quick Sync',
                          onTap: () {}, // TODO: Implement quick sync
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.info_outline,
                                title: 'Details',
                                onTap: () {}, // TODO: Implement details
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.settings,
                                title: 'Configure',
                                onTap: () {}, // TODO: Implement configure
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.medical_services_outlined,
                                title: 'Diagnose',
                                onTap: () {}, // TODO: Implement diagnose
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.history,
                                title: 'History',
                                onTap: () {}, // TODO: Implement history
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _ActionButton(
                          icon: Icons.power_settings_new,
                          title: 'Quick Activate',
                          onTap: () {}, // TODO: Implement quick activate
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary600.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary600),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
