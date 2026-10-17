import 'package:flutter_test/flutter_test.dart';
import 'package:solaris_record_app/src/features/announcements/domain/announcement.dart';

void main() {
  group('parseAnnouncements', () {
    test('reads text as a string or per language', () {
      final list = parseAnnouncements({
        'announcements': [
          {
            'id': 'a',
            'title': 'Plain',
            'body': {'en': 'English', 'id': 'Indonesia'},
          },
        ],
      });
      expect(list, hasLength(1));
      expect(list.single.title, {'en': 'Plain'});
      expect(pickText(list.single.body, 'id'), 'Indonesia');
      expect(pickText(list.single.body, 'fr'), 'English');
    });

    test('skips entries without an id, title or body', () {
      final list = parseAnnouncements({
        'announcements': [
          {'title': 'x', 'body': 'y'},
          {'id': 'a', 'body': 'y'},
          {'id': 'b', 'title': 'x'},
          {'id': 'c', 'title': ' ', 'body': 'y'},
          'not a map',
          {'id': 'ok', 'title': 'x', 'body': 'y'},
        ],
      });
      expect([for (final a in list) a.id], ['ok']);
    });

    test('drops a link that is not https but keeps the notice', () {
      final list = parseAnnouncements({
        'announcements': [
          {
            'id': 'a',
            'title': 't',
            'body': 'b',
            'ctaLabel': 'Open',
            'ctaUrl': 'http://example.com',
          },
          {
            'id': 'b',
            'title': 't',
            'body': 'b',
            'ctaLabel': 'Open',
            'ctaUrl': 'https://example.com/x',
          },
        ],
      });
      expect(list[0].ctaUrl, isNull);
      expect(list[0].ctaLabel, isNull);
      expect(list[1].ctaUrl, 'https://example.com/x');
      expect(pickText(list[1].ctaLabel, 'en'), 'Open');
    });

    test('returns an empty list for anything else', () {
      expect(parseAnnouncements(null), isEmpty);
      expect(parseAnnouncements([]), isEmpty);
      expect(parseAnnouncements({'announcements': 'x'}), isEmpty);
    });
  });

  group('appliesTo', () {
    final now = DateTime.utc(2026, 11, 1);
    Announcement make({
      String? min,
      String? max,
      List<String> platforms = const [],
      DateTime? expires,
    }) => Announcement(
      id: 'a',
      title: const {'en': 't'},
      body: const {'en': 'b'},
      minVersion: min,
      maxVersion: max,
      platforms: platforms,
      expires: expires,
    );

    bool applies(
      Announcement a, {
      String version = '1.2.0',
      String os = 'android',
    }) => a.appliesTo(version: version, platform: os, now: now);

    test('an unrestricted notice applies everywhere', () {
      expect(applies(make()), isTrue);
    });

    test('version bounds are inclusive', () {
      final a = make(min: '1.1.0', max: '1.2.0');
      expect(applies(a, version: '1.0.9'), isFalse);
      expect(applies(a, version: '1.1.0'), isTrue);
      expect(applies(a, version: '1.2.0'), isTrue);
      expect(applies(a, version: '1.2.1'), isFalse);
    });

    test('platforms limit where it shows', () {
      final a = make(platforms: ['android', 'ios']);
      expect(applies(a, os: 'android'), isTrue);
      expect(applies(a, os: 'windows'), isFalse);
    });

    test('it stops applying at its expiry', () {
      expect(applies(make(expires: now.add(const Duration(days: 1)))), isTrue);
      expect(applies(make(expires: now)), isFalse);
      expect(
        applies(make(expires: now.subtract(const Duration(days: 1)))),
        isFalse,
      );
    });
  });
}
