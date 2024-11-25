import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/device_service.dart';
import '../../widgets/status_indicators.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceService>(
      builder: (context, deviceService, child) {
        return Scaffold(
          backgroundColor: AppColors.lightBackdrop,
          body: Column(
            children: [
              // Top Navigation Bar (same as home screen)
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
                          onPressed: () => Navigator.pop(context),
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
                ),
              ),

              // Settings Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Settings Header
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 25,
                          top: 20,
                          right: 25,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings,
                              size: 30,
                              color: AppColors.lightMidGray,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 26,
                                color: AppColors.lightMidGray,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 16,
                        ),
                        child: Container(
                          height: 2,
                          color: AppColors.lightDivider,
                        ),
                      ),

                      // General Settings Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          'General',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),

                      // Settings Card
                      Padding(
                        padding: const EdgeInsets.all(25),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 30,
                            ),
                            child: Column(
                              children: [
                                _buildSettingItem(
                                  title: 'Notifications',
                                  description:
                                      'Enable notifications for device updates and alerts',
                                  value: true,
                                  onChanged: (value) {
                                    // TODO: Implement notifications toggle
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildSettingItem(
                                  title: 'GPS Format',
                                  description:
                                      'Use DMS (Degrees, Minutes, Seconds) format',
                                  value: false,
                                  onChanged: (value) {
                                    // TODO: Implement GPS format toggle
                                  },
                                ),
                                const SizedBox(height: 20),
                                _buildSettingItem(
                                  title: 'Developer Firmware',
                                  description:
                                      'Allow installation of development firmware',
                                  value: false,
                                  onChanged: (value) {
                                    // TODO: Implement developer firmware toggle
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Account Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          'Account',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),

                      // Account Card
                      Padding(
                        padding: const EdgeInsets.all(25),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 30,
                            ),
                            child: Column(
                              children: [
                                _buildInfoItem(
                                  title: 'Email',
                                  value: 'user@example.com',
                                ),
                                const SizedBox(height: 20),
                                _buildInfoItem(
                                  title: 'Name',
                                  value: 'John Doe',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // App Info Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          'App Info',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),

                      // App Info Card
                      Padding(
                        padding: const EdgeInsets.all(25),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 30,
                            ),
                            child: Column(
                              children: [
                                _buildInfoItem(
                                  title: 'App Version',
                                  value: '1.0.0',
                                ),
                                const SizedBox(height: 20),
                                _buildInfoItem(
                                  title: 'Install ID',
                                  value: 'ABC123XYZ',
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildSettingItem({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                description,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary600,
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
