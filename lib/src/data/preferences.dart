import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences.g.dart';

/// Loaded once in `main()` and injected through a ProviderScope override so
/// settings can be read synchronously (no flash of default theme/language).
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('Override sharedPreferencesProvider in main()');
