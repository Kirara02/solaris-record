import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solaris_record_app/src/data/convene_repository.dart';
import 'package:solaris_record_app/src/data/database.dart';
import 'package:solaris_record_app/src/features/import/domain/convene_api.dart';
import 'package:solaris_record_app/src/features/import/domain/convene_url.dart';
import 'package:solaris_record_app/src/features/stats/domain/pool_type.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.respond);
  final ResponseBody Function(RequestOptions) respond;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(String body, [int status = 200]) => ResponseBody.fromString(
  body,
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

const _url = ConveneUrl(
  serverId: 'svr',
  playerId: '100',
  recordId: 'rec',
  language: 'id',
  cardPoolId: 'pool',
);

void main() {
  final fixture = File('test/fixtures/record_response.json').readAsStringSync();

  group('ConveneApi', () {
    test('sends expected body (always English) and parses records', () async {
      final adapter = _FakeAdapter((_) => _json(fixture));
      final api = ConveneApi(Dio()..httpClientAdapter = adapter);
      final records = await api.fetchPool(_url, PoolType.featuredWeapon);

      expect(adapter.last!.uri.toString(), ConveneApi.endpoint);
      expect(adapter.last!.data, {
        'cardPoolId': 'pool',
        'cardPoolType': 2,
        'languageCode': 'en',
        'playerId': '100',
        'recordId': 'rec',
        'serverId': 'svr',
      });
      expect(records, hasLength(3));
      expect(records.first.name, 'Jianxin');
      expect(records.first.rarity, 5);
    });

    test('non-zero code means invalid/expired URL', () async {
      final api = ConveneApi(
        Dio()
          ..httpClientAdapter = _FakeAdapter(
            (_) => _json('{"code":-1,"message":"bad","data":null}'),
          ),
      );
      expect(
        () => api.fetchPool(_url, PoolType.beginner),
        throwsA(
          isA<ConveneApiException>().having(
            (e) => e.error,
            'error',
            ConveneApiError.invalidOrExpired,
          ),
        ),
      );
    });

    test('HTTP 429 maps to rate limited', () async {
      final api = ConveneApi(
        Dio(BaseOptions(validateStatus: (s) => s != null && s < 400))
          ..httpClientAdapter = _FakeAdapter((_) => _json('{}', 429)),
      );
      expect(
        () => api.fetchPool(_url, PoolType.beginner),
        throwsA(
          isA<ConveneApiException>().having(
            (e) => e.error,
            'error',
            ConveneApiError.rateLimited,
          ),
        ),
      );
    });

    test('null data is an empty list', () async {
      final api = ConveneApi(
        Dio()
          ..httpClientAdapter = _FakeAdapter(
            (_) => _json('{"code":0,"message":"ok","data":null}'),
          ),
      );
      expect(await api.fetchPool(_url, PoolType.beginner), isEmpty);
    });
  });

  group('ConveneRepository merge', () {
    late AppDatabase db;
    late ConveneRepository repo;
    late List<RemoteRecord> remote;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = ConveneRepository(db);
      await repo.upsertAccount(uid: '100', serverId: 'svr');
      final api = ConveneApi(
        Dio()..httpClientAdapter = _FakeAdapter((_) => _json(fixture)),
      );
      remote = await api.fetchPool(_url, PoolType.featuredResonator);
    });

    tearDown(() => db.close());

    test(
      'keeps duplicate rows with identical time/name via recordIndex',
      () async {
        expect(
          await repo.mergeRecords('100', PoolType.featuredResonator, remote),
          3,
        );
        final rows = await repo
            .watchRecords('100', PoolType.featuredResonator)
            .first;
        expect(rows.map((r) => r.name), [
          'Training Sword',
          'Training Sword',
          'Jianxin',
        ]);
        expect(rows.map((r) => r.recordIndex), [0, 1, 0]);
      },
    );

    test('re-import is idempotent', () async {
      await repo.mergeRecords('100', PoolType.featuredResonator, remote);
      expect(
        await repo.mergeRecords('100', PoolType.featuredResonator, remote),
        0,
      );
    });

    test(
      'old history survives when the server page no longer has it',
      () async {
        await repo.mergeRecords('100', PoolType.featuredResonator, remote);
        final newer = [
          const RemoteRecord(
            poolType: '',
            time: '2024-07-01 00:00:00',
            name: 'Lumi',
            resourceType: 'Resonator',
            rarity: 4,
            count: 1,
          ),
        ];
        expect(
          await repo.mergeRecords('100', PoolType.featuredResonator, newer),
          1,
        );
        final rows = await repo
            .watchRecords('100', PoolType.featuredResonator)
            .first;
        expect(rows, hasLength(4));
        expect(rows.last.name, 'Lumi');
      },
    );

    test('re-import backfills resourceId on existing rows', () async {
      // Simulates rows stored before schema v2 (resourceId 0).
      final legacy = [
        for (final r in remote)
          RemoteRecord(
            poolType: r.poolType,
            time: r.time,
            name: r.name,
            resourceType: r.resourceType,
            rarity: r.rarity,
            count: r.count,
          ),
      ];
      await repo.mergeRecords('100', PoolType.featuredResonator, legacy);
      var rows = await repo
          .watchRecords('100', PoolType.featuredResonator)
          .first;
      expect(rows.map((r) => r.resourceId), everyElement(0));

      expect(
        await repo.mergeRecords('100', PoolType.featuredResonator, remote),
        0,
      );
      rows = await repo.watchRecords('100', PoolType.featuredResonator).first;
      expect(rows.map((r) => r.resourceId).toSet(), {1105, 21010013});
    });

    test('records are scoped per uid and pool', () async {
      await repo.mergeRecords('100', PoolType.featuredResonator, remote);
      expect(
        await repo.watchRecords('100', PoolType.featuredWeapon).first,
        isEmpty,
      );
      expect(
        await repo.watchRecords('200', PoolType.featuredResonator).first,
        isEmpty,
      );
    });

    test('deleting an account removes its records', () async {
      await repo.mergeRecords('100', PoolType.featuredResonator, remote);
      await repo.deleteAccount('100');
      expect(await repo.watchAccounts().first, isEmpty);
      expect(
        await repo.watchRecords('100', PoolType.featuredResonator).first,
        isEmpty,
      );
    });
  });
}
