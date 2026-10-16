import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solaris_record_app/src/features/info/data/encore_info_service.dart';
import 'package:solaris_record_app/src/features/info/domain/item_info.dart';
import 'package:solaris_record_app/src/features/info/domain/item_kind.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('helpers', () {
    test('itemKindFor prefers the type, then falls back to id length', () {
      expect(itemKindFor(1105, 'Resonator'), ItemKind.resonator);
      expect(itemKindFor(21010011, 'weapon'), ItemKind.weapon);
      expect(itemKindFor(1105, ''), ItemKind.resonator);
      expect(itemKindFor(21010011, 'Item'), ItemKind.weapon);
      expect(itemKindFor(123, ''), isNull);
    });

    test('encoreAssetUrl turns asset paths into webp URLs', () {
      expect(
        encoreAssetUrl(
          '/Game/Aki/UI/UIResources/Common/Image/IconWeapon732/'
          'T_IconWeapon732_21010011_UI.T_IconWeapon732_21010011_UI',
        ),
        'https://api-v2.encore.moe/resource/Data/Game/Aki/UI/UIResources/'
        'Common/Image/IconWeapon732/T_IconWeapon732_21010011_UI.webp',
      );
      expect(
        encoreAssetUrl('https://x.example/a.webp'),
        'https://x.example/a.webp',
      );
      expect(encoreAssetUrl(''), isNull);
      expect(encoreAssetUrl(null), isNull);
    });

    test('stripHtml removes tags and keeps line breaks', () {
      expect(
        stripHtml(
          'Deals <span style="color:#fff">Glacio DMG</span>.<br><br>Next',
        ),
        'Deals Glacio DMG.\n\nNext',
      );
      expect(stripHtml('a&nbsp;&amp;&nbsp;b'), 'a & b');
      expect(stripHtml('<size=10></span>x'), 'x');
    });
  });

  group('parsers (real encore responses)', () {
    test('character', () {
      final info = parseCharacter(fixture('encore_character.json'))!;
      expect(info.kind, ItemKind.resonator);
      expect(info.name, 'Zhezhi');
      expect(info.rarity, 5);
      expect(info.elementName, 'Glacio');
      expect(info.typeName, 'Rectifier');
      expect(info.description, startsWith('An artist for hire'));
      expect(info.imageUrl, contains('T_IconRole_Pile_zhezhi_UI.webp'));
      expect(info.tags, ['Concerto Efficiency', 'Basic Attack DMG']);
      expect(info.skills.first.type, 'Normal Attack');
      expect(info.skills.first.name, 'Dimming Brush');
      // Only plain numbers: ratio stats (Crit. Rate 500) are left out.
      expect(info.stats.map((s) => '${s.name} ${s.value}'), [
        'HP 980',
        'ATK 30',
        'DEF 98',
      ]);
    });

    test('weapon', () {
      final info = parseWeapon(fixture('encore_weapon.json'))!;
      expect(info.kind, ItemKind.weapon);
      expect(info.name, 'Training Broadblade');
      expect(info.rarity, 1);
      expect(info.typeName, 'Broadblade');
      expect(info.effectName, 'Persevere');
      expect(info.effectDescription, 'Increases ATK by 4%/5%/6%/7%/8%.');
      expect(info.imageUrl, endsWith('T_IconWeapon732_21010011_UI.webp'));
      expect(info.stats.single.name, 'ATK');
      expect(info.stats.single.value, '20');
    });

    test('an empty name means no usable translation', () {
      expect(
        parseCharacter({
          'Name': {'Title': '', 'Content': ''},
          'NickName': {'Content': ''},
        }),
        isNull,
      );
      expect(parseWeapon({'WeaponName': ''}), isNull);
    });
  });

  group('EncoreInfoService', () {
    test('builds the language-specific endpoint and parses the body', () async {
      final urls = <String>[];
      final service = EncoreInfoService(
        loadJson: (url) async {
          urls.add(url);
          return File('test/fixtures/encore_character.json').readAsString();
        },
      );
      final info = await service.fetch(1105, 'Resonator', 'id');
      expect(urls, ['https://api-v2.encore.moe/api/id/character/1105']);
      expect(info!.name, 'Zhezhi');
    });

    test(
      'falls back to English when the language has no translation',
      () async {
        final urls = <String>[];
        final service = EncoreInfoService(
          loadJson: (url) async {
            urls.add(url);
            return url.contains('/id/')
                ? jsonEncode({
                    'Name': {'Content': ''},
                    'NickName': {'Content': ''},
                  })
                : File('test/fixtures/encore_character.json').readAsString();
          },
        );
        final info = await service.fetch(1105, 'Resonator', 'id');
        expect(urls, [
          'https://api-v2.encore.moe/api/id/character/1105',
          'https://api-v2.encore.moe/api/en/character/1105',
        ]);
        expect(info!.name, 'Zhezhi');
      },
    );

    test('unsupported languages use English; weapons use /weapon/', () async {
      final urls = <String>[];
      final service = EncoreInfoService(
        loadJson: (url) async {
          urls.add(url);
          return File('test/fixtures/encore_weapon.json').readAsString();
        },
      );
      await service.fetch(21010011, 'Weapon', 'xx');
      expect(urls.single, 'https://api-v2.encore.moe/api/en/weapon/21010011');
    });

    test('non-resonator/weapon ids return null without any request', () async {
      var calls = 0;
      final service = EncoreInfoService(
        loadJson: (_) async {
          calls++;
          return '{}';
        },
      );
      expect(await service.fetch(123, '', 'en'), isNull);
      expect(await service.fetch(0, 'Weapon', 'en'), isNull);
      expect(calls, 0);
    });

    test('network failures propagate so the UI can offer a retry', () {
      final service = EncoreInfoService(
        loadJson: (_) async => throw const FormatException('offline'),
      );
      expect(
        () => service.fetch(1105, 'Resonator', 'en'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
