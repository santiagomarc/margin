import 'package:flutter/services.dart';

/// The Android device, from the `margin/device` channel in MainActivity.kt.
class DeviceInfo {
  const DeviceInfo({
    this.manufacturer = 'unknown',
    this.model = 'unknown',
    this.androidVersion = '?',
    this.sdk = 0,
    this.totalRamMb = 0,
    this.memoryClassMb = 0,
    this.lowRamDevice = false,
  });

  static const _channel = MethodChannel('margin/device');

  final String manufacturer;
  final String model;
  final String androidVersion;
  final int sdk;
  final int totalRamMb;

  /// Java heap limit per app; hints at how Android ranks the device.
  final int memoryClassMb;
  final bool lowRamDevice;

  static Future<DeviceInfo> load() async {
    try {
      final info = await _channel.invokeMapMethod<String, Object?>('info');
      if (info == null) return const DeviceInfo();
      return DeviceInfo(
        manufacturer: info['manufacturer'] as String? ?? 'unknown',
        model: info['model'] as String? ?? 'unknown',
        androidVersion: info['android'] as String? ?? '?',
        sdk: info['sdk'] as int? ?? 0,
        totalRamMb: info['totalRamMb'] as int? ?? 0,
        memoryClassMb: info['memoryClassMb'] as int? ?? 0,
        lowRamDevice: info['lowRamDevice'] as bool? ?? false,
      );
    } on MissingPluginException {
      return const DeviceInfo();
    } on PlatformException {
      return const DeviceInfo();
    }
  }

  String describe() =>
      '$manufacturer $model, Android $androidVersion (SDK $sdk), '
      'RAM $totalRamMb MB, app heap class $memoryClassMb MB'
      '${lowRamDevice ? ', low-RAM device' : ''}';
}
