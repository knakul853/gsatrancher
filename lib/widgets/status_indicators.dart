import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusIndicators extends StatelessWidget {
  final bool isBluetoothEnabled;
  final bool isLocationEnabled;

  const StatusIndicators({
    Key? key,
    required this.isBluetoothEnabled,
    required this.isLocationEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIndicator(
          Icons.bluetooth,
          isBluetoothEnabled,
          'Bluetooth ${isBluetoothEnabled ? 'On' : 'Off'}',
        ),
        const SizedBox(width: 16),
        _buildIndicator(
          Icons.location_on,
          isLocationEnabled,
          'Location ${isLocationEnabled ? 'On' : 'Off'}',
        ),
      ],
    );
  }

  Widget _buildIndicator(IconData icon, bool isEnabled, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Icon(
        icon,
        color: AppColors.lightHighEmphasis,  // Always white (#FFFFFF)
        size: 24,
      ),
    );
  }
}
