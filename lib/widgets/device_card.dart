import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DeviceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isEnabled;

  const DeviceCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Card(
        elevation: 2,
        color: AppColors.lightBackground,
        margin: const EdgeInsets.all(8),
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          child: Container(
            width: 150,
            height: 150,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: isEnabled ? AppColors.primary500 : AppColors.lightBackdropMid,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isEnabled ? AppColors.secondary700 : AppColors.lightBackdropMid,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
