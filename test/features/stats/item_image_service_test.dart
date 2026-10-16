import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solaris_record_app/src/features/stats/data/item_image_service.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final ResponseBody Function(RequestOptions) respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(String body) => ResponseBody.fromString(
  body,
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

const _guide =
    '{"code":200,"message":"ok","data":[{"id":1,"role":{"roleGbId":"1105",'
    '"cardPictureUrl":"https://guide-res.example/card.png",'
    '"illustrationPictureUrl":"https://guide-res.example/big.png","star":5}}]}';

void main() {
  late SharedPreferences prefs;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('weapon icon URL is derived from the resource id, no request', () async {
    final adapter = _Adapter((_) => _json('{}'));
    final service = ItemImageService(Dio()..httpClientAdapter = adapter, prefs);
    final url = await service.urlFor(21010011, 'Weapon');
    expect(url, endsWith('/IconWeapon/T_IconWeapon21010011_UI.webp'));
    expect(adapter.requests, isEmpty);
  });

  test('resonator URL comes from the guide server and is cached', () async {
    final adapter = _Adapter((_) => _json(_guide));
    final service = ItemImageService(Dio()..httpClientAdapter = adapter, prefs);

    expect(
      await service.urlFor(1105, 'Resonator'),
      'https://guide-res.example/card.png',
    );
    expect(adapter.requests.single.queryParameters, {'roleGbId': 1105});
    expect(adapter.requests.single.headers['X-Language'], 'en');

    // Second lookup is served from prefs.
    await service.urlFor(1105, 'Resonator');
    expect(adapter.requests, hasLength(1));

    await service.clearCachedUrls();
    await service.urlFor(1105, 'Resonator');
    expect(adapter.requests, hasLength(2));
  });

  test('falls back to id length when the type is unrecognised', () async {
    final service = ItemImageService(
      Dio()..httpClientAdapter = _Adapter((_) => _json(_guide)),
      prefs,
    );
    expect(await service.urlFor(21010011, ''), isNotNull); // 8 digits: weapon
    expect(await service.urlFor(1105, ''), isNotNull); // 4 digits: resonator
    expect(await service.urlFor(123, ''), isNull);
    expect(await service.urlFor(0, 'Weapon'), isNull);
  });

  test('failures resolve to null and are not cached', () async {
    final failing = _Adapter((_) => _json('{"code":500,"data":null}'));
    final service = ItemImageService(Dio()..httpClientAdapter = failing, prefs);
    expect(await service.urlFor(1105, 'Resonator'), isNull);
    expect(prefs.getKeys(), isEmpty);

    final broken = _Adapter(
      (o) => throw DioException(requestOptions: o, message: 'offline'),
    );
    final offline = ItemImageService(Dio()..httpClientAdapter = broken, prefs);
    expect(await offline.urlFor(1105, 'Resonator'), isNull);
  });
}
