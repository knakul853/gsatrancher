import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'status_icon.dart';

class DeviceListItem extends StatelessWidget {
  final String deviceName;
  final String version;
  final bool hasUpdate;
  final int batteryLevel;
  final int signalStrength;
  final bool isSelected;
  final Function(bool?)? onSelectionChanged;
  final VoidCallback? onTap;

  const DeviceListItem({
    super.key,
    required this.deviceName,
    required this.version,
    this.hasUpdate = false,
    required this.batteryLevel,
    required this.signalStrength,
    this.isSelected = false,
    this.onSelectionChanged,
    this.onTap,
  });

  String _getSignalStrengthText(int strength) {
    if (strength >= 75) return 'STRONG';
    if (strength >= 50) return 'GOOD';
    if (strength >= 25) return 'FAIR';
    return 'WEAK';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6.5),
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 0,
          color: AppColors.lightBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                if (onSelectionChanged != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: onSelectionChanged,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deviceName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.secondary700,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              Text(
                                version,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.secondary200,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (hasUpdate)
                                Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary500,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'UPDATE FIRMWARE',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            children: [
                              StatusIcon.battery(batteryLevel),
                              const SizedBox(height: 6),
                              Text(
                                '$batteryLevel%',
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.black,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Column(
                            children: [
                              StatusIcon.signal(signalStrength),
                              const SizedBox(height: 7),
                              Text(
                                _getSignalStrengthText(signalStrength),
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.black,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
