import 'package:dio/dio.dart';

import '../../stats/domain/pool_type.dart';
import 'convene_url.dart';

/// A record as returned by the API (newest first within a pool).
class RemoteRecord {
  const RemoteRecord({
    required this.poolType,
    this.resourceId = 0,
    required this.time,
    required this.name,
    required this.resourceType,
    required this.rarity,
    required this.count,
  });

  factory RemoteRecord.fromJson(Map<String, dynamic> json) => RemoteRecord(
    poolType: json['cardPoolType'] as String? ?? '',
    resourceId: (json['resourceId'] as num?)?.toInt() ?? 0,
    time: json['time'] as String,
    name: json['name'] as String,
    resourceType: json['resourceType'] as String? ?? '',
    rarity: (json['qualityLevel'] as num).toInt(),
    count: (json['count'] as num?)?.toInt() ?? 1,
  );

  final String poolType;
  final int resourceId;
  final String time;
  final String name;
  final String resourceType;
  final int rarity;
  final int count;
}

enum ConveneApiError { invalidOrExpired, rateLimited, network, unexpected }

class ConveneApiException implements Exception {
  const ConveneApiException(this.error, [this.detail]);

  final ConveneApiError error;
  final String? detail;

  @override
  String toString() => 'ConveneApiException($error, $detail)';
}

/// Single place that knows the Kuro convene record endpoint.
class ConveneApi {
  ConveneApi(this._dio);

  static const endpoint =
      'https://gmserver-api.aki-game2.net/gacha/record/query';

  final Dio _dio;

  /// Records are always requested in English so names are stable across
  /// imports (the 50/50 detection relies on English names).
  Future<List<RemoteRecord>> fetchPool(ConveneUrl url, PoolType pool) async {
    final Response<dynamic> response;
    try {
      response = await _dio.post<dynamic>(
        endpoint,
        data: {
          'cardPoolId': url.poolIdParam,
          'cardPoolType': pool.id,
          'languageCode': 'en',
          'playerId': url.playerId,
          'recordId': url.recordId,
          'serverId': url.serverId,
        },
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const ConveneApiException(ConveneApiError.rateLimited);
      }
      throw ConveneApiException(ConveneApiError.network, e.message);
    }

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const ConveneApiException(ConveneApiError.unexpected);
    }
    if (body['code'] != 0) {
      throw ConveneApiException(
        ConveneApiError.invalidOrExpired,
        body['message']?.toString(),
      );
    }
    final data = body['data'];
    if (data == null) return const [];
    if (data is! List) {
      throw const ConveneApiException(ConveneApiError.unexpected);
    }
    try {
      return [
        for (final item in data)
          RemoteRecord.fromJson(item as Map<String, dynamic>),
      ];
    } on Object catch (e) {
      throw ConveneApiException(ConveneApiError.unexpected, '$e');
    }
  }
}
