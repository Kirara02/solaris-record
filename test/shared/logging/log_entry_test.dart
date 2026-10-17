import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:solaris_record_app/src/shared/logging/app_log.dart';

void main() {
  test('a log line has the time, level, logger and message', () {
    final entry = LogEntry(
      time: DateTime.utc(2026, 10, 17, 8, 47, 45),
      level: Level.WARNING,
      logger: 'update',
      message: 'Update check failed',
    );
    expect(
      entry.text,
      '2026-10-17T08:47:45.000Z WARNING [update] Update check failed',
    );
  });

  test('error and stack trace follow on their own lines', () {
    final entry = LogEntry(
      time: DateTime.utc(2026),
      level: Level.SEVERE,
      logger: 'app',
      message: 'boom',
      error: 'StateError: bad',
      stackTrace: '#0 main',
    );
    expect(entry.text.split('\n').skip(1), [
      '  error: StateError: bad',
      '#0 main',
    ]);
  });
}
