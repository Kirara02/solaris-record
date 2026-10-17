import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solaris_record_app/src/data/preferences.dart';
import 'package:solaris_record_app/src/features/stats/stats_providers.dart';

Future<ProviderContainer> container(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  final c = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('the 5★ overview defaults to the card grid', () async {
    final c = await container({});
    expect(c.read(fiveStarStyleChoiceProvider), FiveStarStyle.grid);
  });

  test('an unknown saved style falls back to the grid', () async {
    final c = await container({'five_star_style': 'bogus'});
    expect(c.read(fiveStarStyleChoiceProvider), FiveStarStyle.grid);
  });

  test('the chosen style is saved and read back', () async {
    final c = await container({});
    await c
        .read(fiveStarStyleChoiceProvider.notifier)
        .set(FiveStarStyle.bubbles);

    final prefs = c.read(sharedPreferencesProvider);
    final reloaded = await container({
      for (final k in prefs.getKeys()) k: prefs.get(k)!,
    });
    expect(reloaded.read(fiveStarStyleChoiceProvider), FiveStarStyle.bubbles);
  });
}
