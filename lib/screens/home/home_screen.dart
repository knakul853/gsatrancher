import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/device_card.dart';
import '../../widgets/status_indicators.dart';
import '../../services/device_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceService>(
      builder: (context, deviceService, child) {
        final bool isConnected = deviceService.isConnected;

        return Scaffold(
          backgroundColor: AppColors.lightBackdrop,
          appBar: AppBar(
            backgroundColor: AppColors.primary600,
            title: const Text(''),
            actions: [
              StatusIndicators(
                isBluetoothEnabled: deviceService.isBluetoothEnabled,
                isLocationEnabled: deviceService.isLocationEnabled,
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: Column(
            children: [
              Container(
                color: AppColors.primary700,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
              ),
              _buildConnectionStatus(isConnected),
              Expanded(
                child: isConnected
                    ? _buildConnectedDeviceCards(context)
                    : _buildDisconnectedDeviceCards(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConnectionStatus(bool isConnected) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: isConnected ? AppColors.lightPositive : AppColors.lightNegative,
      child: Text(
        isConnected ? 'Device Connected' : 'Device Disconnected',
        style: TextStyle(
          color: AppColors.lightHighEmphasis,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDisconnectedDeviceCards(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: [
        DeviceCard(
          title: 'Connect to Device',
          icon: Icons.bluetooth_searching,
          onTap: () {
            // TODO: Implement connect to device
          },
        ),
        DeviceCard(
          title: 'Update Device',
          icon: Icons.system_update,
          onTap: () {
            // TODO: Implement update device
          },
          isEnabled: false,
        ),
        DeviceCard(
          title: 'Fast Pass',
          icon: Icons.speed,
          onTap: () {
            // TODO: Implement fast pass
          },
          isEnabled: false,
        ),
        DeviceCard(
          title: 'Settings',
          icon: Icons.settings,
          onTap: () {
            // TODO: Navigate to settings
          },
        ),
        DeviceCard(
          title: 'Support',
          icon: Icons.help_outline,
          onTap: () {
            // TODO: Navigate to support
          },
        ),
      ],
    );
  }

  Widget _buildConnectedDeviceCards(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: [
        DeviceCard(
          title: 'Device Details',
          icon: Icons.info_outline,
          onTap: () {
            // TODO: Navigate to device details
          },
        ),
        DeviceCard(
          title: 'Configuration',
          icon: Icons.settings_applications,
          onTap: () {
            // TODO: Navigate to configuration
          },
        ),
        DeviceCard(
          title: 'Diagnostics',
          icon: Icons.assessment,
          onTap: () {
            // TODO: Navigate to diagnostics
          },
        ),
        DeviceCard(
          title: 'Skip Activation',
          icon: Icons.skip_next,
          onTap: () {
            // TODO: Implement skip activation
          },
        ),
        DeviceCard(
          title: 'Settings',
          icon: Icons.settings,
          onTap: () {
            // TODO: Navigate to settings
          },
        ),
        DeviceCard(
          title: 'Support',
          icon: Icons.help_outline,
          onTap: () {
            // TODO: Navigate to support
          },
        ),
        DeviceCard(
          title: 'Update Device',
          icon: Icons.system_update,
          onTap: () {
            // TODO: Implement update device
          },
        ),
      ],
    );
  }
}
