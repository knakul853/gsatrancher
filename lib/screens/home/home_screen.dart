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

        return Scaffold(
          backgroundColor: AppColors.lightBackdrop,
          body: Column(
            children: [
              // Top Navigation Bar
              Container(
                color: AppColors.primary600,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu),
                              color: Colors.white,
                              onPressed: () {
                                // TODO: Implement menu
                              },
                            ),
                            Row(
                              children: [
                                StatusIndicators(
                                  isBluetoothEnabled:
                                      deviceService.isBluetoothEnabled,
                                  isLocationEnabled:
                                      deviceService.isLocationEnabled,
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30), // Space for the floating card
                    ],
                  ),
                ),
              ),

              // Floating Connection Status Card
              Transform.translate(
                offset: const Offset(0, -30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Card(
                    elevation: 15,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      child: Row(
                        children: [
                          Text(
                            isConnected ? 'CONNECTED' : 'DISCONNECTED',
                            style: TextStyle(
                              fontSize: 26,
                              color: isConnected
                                  ? AppColors.primary600
                                  : AppColors.lightBackdrop,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          if (isConnected)
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                // TODO: Implement disconnect
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Scrollable Content Area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: [
                            DeviceCard(
                              title: 'Connect to Device',
                              icon: Icons.bluetooth_searching,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const ScanScreen()),
                                );
                              },
                            ),
                            DeviceCard(
                              title: 'Update Device',
                              icon: Icons.system_update,
                              onTap: () {
                                // TODO: Implement update device
                              },
                              isEnabled: isConnected,
                            ),
                            DeviceCard(
                              title: 'Fast Pass',
                              icon: Icons.speed,
                              onTap: () {
                                // TODO: Implement fast pass
                              },
                              isEnabled: isConnected,
                            ),
                            DeviceCard(
                              title: 'Settings',
                              icon: Icons.settings,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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
