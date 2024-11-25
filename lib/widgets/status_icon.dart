import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const StatusIcon({
    super.key,
    required this.icon,
    this.size = 24,
  });

  static Widget battery(int level, {double size = 24}) {
    IconData icon;
    if (level >= 87.5) {
      icon = Icons.battery_full;
    } else if (level >= 62.5) {
      icon = Icons.battery_6_bar;
    } else if (level >= 37.5) {
      icon = Icons.battery_4_bar;
    } else if (level >= 12.5) {
      icon = Icons.battery_2_bar;
    } else {
      icon = Icons.battery_0_bar;
    }
    return StatusIcon(icon: icon, size: size);
  }

  static Widget signal(int strength, {double size = 24}) {
    IconData icon;
    if (strength >= 87.5) {
      icon = Icons.signal_cellular_4_bar;
    } else if (strength >= 62.5) {
      icon = Icons.signal_cellular_alt_2_bar;
    } else if (strength >= 37.5) {
      icon = Icons.signal_cellular_alt_1_bar;
    } else if (strength >= 12.5) {
      icon = Icons.signal_cellular_alt;
    } else {
      icon = Icons.signal_cellular_0_bar;
    }
    return StatusIcon(icon: icon, size: size);
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
    );
  }
}
