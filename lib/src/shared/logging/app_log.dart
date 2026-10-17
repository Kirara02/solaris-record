import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// One logged record, kept for the in-app log viewer.
class LogEntry {
  const LogEntry({
    required this.time,
    required this.level,
    required this.logger,
    required this.message,
    this.error,
    this.stackTrace,
  });

  final DateTime time;
  final Level level;
  final String logger;
  final String message;
  final String? error;
  final String? stackTrace;

  /// The line(s) written to the log file.
  String get text {
    final out = StringBuffer(
      '${time.toIso8601String()} ${level.name.padRight(7)} [$logger] $message',
    );
    if (error != null) out.write('\n  error: $error');
    if (stackTrace != null) out.write('\n$stackTrace');
    return out.toString();
  }
}

/// App-wide debug log: every `Logger` record goes to a daily file under the
/// app support directory (kept for a week) and to a short in-memory buffer,
/// which is all there is on the web. Users export it from Data & storage.
///
/// Log messages are English, and must never contain a UID, a convene URL or a
/// token: pass them through `sanitizeUid` / `sanitizeUrl` first.
class AppLog {
  AppLog._();

  static const _keepDays = 7;
  static const _maxFileBytes = 2 * 1024 * 1024;
  static const _bufferLines = 500;

  static Directory? _dir;
  static final _buffer = ListQueue<LogEntry>();
  static final _full = <String>{};

  /// Starts listening to all loggers. Call once before `runApp`.
  static Future<void> init() async {
    setDetailed(false);
    Logger.root.onRecord.listen(_onRecord);
    if (kIsWeb) return;
    try {
      final base = await getApplicationSupportDirectory();
      final dir = Directory(p.join(base.path, 'logs'));
      await dir.create(recursive: true);
      _dir = dir;
      _prune(dir);
    } on Object catch (e) {
      // No file logging, but the in-memory buffer still works.
      debugPrint('AppLog: no log directory ($e)');
    }
  }

  /// Turns on fine-grained logging (on by default in debug builds), for bug
  /// reports. Release builds log at INFO otherwise.
  static void setDetailed(bool on) =>
      Logger.root.level = on || kDebugMode ? Level.ALL : Level.INFO;

  /// The records kept in memory (this session, newest last).
  static List<LogEntry> get entries => List.unmodifiable(_buffer);

  static String _fileName(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return 'solaris-${t.year}-${two(t.month)}-${two(t.day)}.log';
  }

  static void _prune(Directory dir) {
    final cutoff = DateTime.now().subtract(const Duration(days: _keepDays));
    for (final f in dir.listSync().whereType<File>()) {
      if (f.statSync().modified.isBefore(cutoff)) f.deleteSync();
    }
  }

  static void _onRecord(LogRecord r) {
    final entry = LogEntry(
      time: r.time,
      level: r.level,
      logger: r.loggerName,
      message: r.message,
      error: r.error?.toString(),
      stackTrace: r.stackTrace?.toString(),
    );
    final line = entry.text;

    _buffer.add(entry);
    if (_buffer.length > _bufferLines) _buffer.removeFirst();
    if (kDebugMode) debugPrint(line);
    _append(r.time, line);
  }

  static void _append(DateTime time, String line) {
    final dir = _dir;
    if (dir == null) return;
    try {
      final file = File(p.join(dir.path, _fileName(time)));
      if (file.existsSync() && file.lengthSync() > _maxFileBytes) {
        // One marker per file instead of letting a runaway loop fill the disk.
        if (_full.add(file.path)) {
          file.writeAsStringSync(
            '${time.toIso8601String()} WARNING [log] size limit reached\n',
            mode: FileMode.append,
          );
        }
        return;
      }
      file.writeAsStringSync('$line\n', mode: FileMode.append);
    } on Object {
      // Logging must never break the app.
    }
  }

  static List<File> _files() {
    final dir = _dir;
    if (dir == null || !dir.existsSync()) return const [];
    return dir.listSync().whereType<File>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  /// Total size of the stored log files in bytes.
  static Future<int> size() async {
    var total = 0;
    for (final f in _files()) {
      total += await f.length();
    }
    return total;
  }

  /// All stored logs, oldest first, under a header naming [info] (version,
  /// platform, ...). Falls back to the in-memory buffer without files.
  static Future<String> collect({required String info}) async {
    final out = StringBuffer('$info\n\n');
    final files = _files();
    if (files.isEmpty) {
      out.writeAll(_buffer.map((e) => e.text), '\n');
    } else {
      for (final f in files) {
        out.writeln('--- ${p.basename(f.path)} ---');
        out.write(await f.readAsString());
      }
    }
    return out.toString();
  }

  /// Whether there is anything to export.
  static bool get hasLogs => _files().isNotEmpty || _buffer.isNotEmpty;

  /// Deletes every stored log and empties the buffer.
  static Future<void> clear() async {
    _buffer.clear();
    _full.clear();
    for (final f in _files()) {
      try {
        await f.delete();
      } on Object {
        // Locked by another process: leave it.
      }
    }
  }
}
