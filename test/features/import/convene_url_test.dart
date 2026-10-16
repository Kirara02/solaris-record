import 'package:flutter_test/flutter_test.dart';
import 'package:solaris_record_app/src/features/import/domain/convene_url.dart';

void main() {
  const base =
      'https://aki-gm-resources-oversea.aki-game.net/aki/gacha/index.html';

  test('parses fragment params', () {
    final url = parseConveneUrl(
      '$base#/record?svr_id=76402e5b&player_id=100000001&lang=en'
      '&gacha_id=1&gacha_type=1&svr_area=global&record_id=abc123&resources_id=r1',
    );
    expect(url.serverId, '76402e5b');
    expect(url.playerId, '100000001');
    expect(url.recordId, 'abc123');
    expect(url.language, 'en');
    expect(url.poolIdParam, 'r1');
    expect(url.gachaType, '1');
  });

  test('falls back to normal query and trims whitespace', () {
    final url = parseConveneUrl(
      '  $base?svr_id=s&player_id=p&record_id=r&gacha_id=9\n',
    );
    expect(url.playerId, 'p');
    expect(url.poolIdParam, '9');
    expect(url.language, 'en');
  });

  test('reports missing params', () {
    expect(
      () => parseConveneUrl('$base#/record?svr_id=s'),
      throwsA(
        isA<ConveneUrlException>().having((e) => e.missing, 'missing', [
          'player_id',
          'record_id',
        ]),
      ),
    );
  });

  test('rejects non-URLs', () {
    expect(() => parseConveneUrl('hello'), throwsA(isA<ConveneUrlException>()));
  });
}
