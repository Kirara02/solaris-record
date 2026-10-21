import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/preferences.dart';
import 'data/redeem_service.dart';

part 'redeem_providers.g.dart';

@Riverpod(keepAlive: true)
RedeemService redeemService(Ref ref) => RedeemService(
  Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    ),
  ),
  ref.watch(sharedPreferencesProvider),
);

/// The redeem screen offers its own retry and refresh, so don't retry silently.
Duration? _noRetry(int retryCount, Object error) => null;

/// The code list. Invalidate to refresh.
@Riverpod(retry: _noRetry)
Future<RedeemFeed> redeemCodes(Ref ref) =>
    ref.watch(redeemServiceProvider).fetch();
