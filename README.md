# GSA Rancher

A Flutter-based Bluetooth Low Energy (BLE) device management application that allows users to scan, connect, and interact with BLE devices.

## Features

- 🔍 Real-time BLE device scanning
- 📱 Modern Material Design 3 UI
- 📊 Detailed device information display
- 🔐 Automated permission handling
- 📍 Location services integration
- 💫 Smooth animations and transitions

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK (>=3.4.3)
- Dart SDK (>=3.4.3)
- iOS development tools (for iOS deployment)
- Android development tools (for Android deployment)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/gsatrancher.git
cd gsatrancher
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## Dependencies

- `flutter_blue_plus: ^1.31.8` - For BLE functionality
- `provider: ^6.1.1` - State management
- `permission_handler: ^11.0.1` - Permission management
- `lottie: ^3.1.0` - Animation support
- `flutter_svg: ^2.0.10+1` - SVG rendering
- `device_info_plus: ^9.1.2` - Device information
- `location: ^5.0.3` - Location services

## Usage

1. Launch the application
2. Grant necessary permissions when prompted (Bluetooth, Location)
3. Use the scan button to start searching for nearby BLE devices
4. Select a device from the list to view more details or connect

## Permissions Required

The app requires the following permissions:
- Bluetooth (for device scanning and connection)
- Location (required for BLE scanning on Android)
- Bluetooth Admin (for managing BLE state)

## Architecture

The application follows a service-based architecture with:
- `BleService` - Manages Bluetooth operations
- `PermissionService` - Handles permission requests
- `DeviceService` - Manages device state and interactions

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue in the repository or contact the development team.
