import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../widgets/status_indicators.dart';
import '../../services/ble_service.dart';
import '../../widgets/device_list_item.dart';
import '../../models/device_advertising_data.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late BleService _bleService;

  @override
  void initState() {
    super.initState();
    // Get BleService reference
    _bleService = context.read<BleService>();
    // Start scanning when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _bleService.startScan(context);
      }
    });
  }

  @override
  void dispose() {
    _bleService.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BleService>(
      builder: (context, bleService, child) {
        return WillPopScope(
          onWillPop: () async {
            await bleService.stopScan();
            return true;
          },
          child: Scaffold(
            backgroundColor: AppColors.lightBackdrop,
            appBar: AppBar(
              backgroundColor: AppColors.primary600,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.lightHighEmphasis),
                onPressed: () async {
                  await bleService.stopScan();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              title: const Text(''),
              actions: const [
                StatusIndicators(
                  isBluetoothEnabled: true, // TODO: Get actual state
                  isLocationEnabled: true, // TODO: Get actual state
                ),
                SizedBox(width: 16),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: AppColors.primary700,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                ),
                // Action Cards
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.qr_code_scanner,
                          label: 'Scan QR',
                          onTap: () {
                            // TODO: Implement QR scanning
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.filter_list,
                          label: 'Filter',
                          onTap: () {
                            // TODO: Implement filtering
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider with primary color
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 1,
                  color: AppColors.primary600,
                ),
                // Devices Header
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'My Devices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary700,
                    ),
                  ),
                ),
                // Device List or Loading Message
                Expanded(
                  child: _buildDeviceList(
                      bleService.devices, bleService.isScanning),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.lightBackground,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: AppColors.primary500,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.secondary700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceList(List<ScanResult> devices, bool isScanning) {
    if (isScanning && devices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Searching for devices...',
              style: TextStyle(
                color: AppColors.secondary700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (!isScanning && devices.isEmpty) {
      return const Center(
        child: Text(
          'No devices found',
          style: TextStyle(
            color: AppColors.secondary700,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final scanResult = devices[index];
        final deviceName = scanResult.advertisementData.advName.isNotEmpty
            ? scanResult.advertisementData.advName
            : scanResult.device.remoteId.toString();

        // Get manufacturing data if available
        final manufacturingData =
            Provider.of<BleService>(context, listen: false)
                .getParsedManufacturingData(scanResult);

        // Convert RSSI to signal strength percentage
        final signalStrength = _calculateSignalStrength(scanResult.rssi);

        return DeviceListItem(
          deviceName: deviceName,
          version: manufacturingData?.version?.formattedVersion ?? 'v0.0.0',
          hasUpdate: false, // TODO: Implement version check
          batteryLevel: manufacturingData?.stateOfCharge ?? 0,
          signalStrength: signalStrength,
          onTap: () {
            debugPrint('Selected device: $deviceName');
            // TODO: Handle device selection
          },
        );
      },
    );
  }

  int _calculateSignalStrength(int rssi) {
    // Convert RSSI to percentage (typical RSSI range: -100 dBm to -50 dBm)
    const int maxRssi = -50;
    const int minRssi = -100;

    if (rssi >= maxRssi) return 100;
    if (rssi <= minRssi) return 0;

    return ((rssi - minRssi) * 100 ~/ (maxRssi - minRssi)).clamp(0, 100);
  }
}
