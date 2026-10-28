import 'package:intl/intl.dart';

import 'gen/strings.g.dart';

/// Groups thousands by the app language: 10000 becomes 10.000 in Indonesian
/// and 10,000 in English.
String formatNumber(num value) =>
    NumberFormat.decimalPattern(LocaleSettings.currentLocale.languageTag)
        .format(value);
