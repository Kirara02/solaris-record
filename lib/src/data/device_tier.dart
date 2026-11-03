import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How much glass the device can draw, decided once at startup.
///
/// The RAM tiers describe Android hardware, where the full refractive glass
/// is heavy on small phones. Every other platform is [high].
enum DeviceTier {
  /// Arm32-only or low-RAM Android: no backdrop effects by default.
  low,

  /// Mid-range Android: translucent surfaces over one backdrop blur.
  standard,

  /// Everything else: the full refractive glass.
  high,
}

const _tierKey = 'device_tier';
final _log = Logger('device');

/// Set from `main()` (see [resolveDeviceTier]); the default suits tests.
final deviceTierProvider = Provider<DeviceTier>((ref) => DeviceTier.high);

/// The device's tier. Android is measured once and remembered, so a launch
/// does not wait on the platform again.
Future<DeviceTier> resolveDeviceTier(SharedPreferences prefs) async {
  if (kIsWeb || !Platform.isAndroid) return DeviceTier.high;
  final cached = DeviceTier.values.asNameMap()[prefs.getString(_tierKey)];
  if (cached != null) return cached;
  try {
    final info = await DeviceInfoPlugin().androidInfo;
    final low =
        info.supported64BitAbis.isEmpty ||
        info.isLowRamDevice ||
        info.physicalRamSize <= 2500;
    final tier = low
        ? DeviceTier.low
        : info.physicalRamSize >= 6000
        ? DeviceTier.high
        : DeviceTier.standard;
    await prefs.setString(_tierKey, tier.name);
    _log.info('Device tier=${tier.name} ram=${info.physicalRamSize}MB');
    return tier;
  } on Object catch (e) {
    _log.warning('Could not read the device profile: $e');
    return DeviceTier.standard;
  }
}
