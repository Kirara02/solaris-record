import 'dart:convert';

/// Value of the `app` field in files written by this app.
const backupAppId = 'solaris_record';

/// Highest `schema_version` this build can read.
const backupSchemaVersion = 1;

/// The file isn't a backup of this app or of a supported platform.
class ForeignBackupException implements Exception {
  const ForeignBackupException();

  @override
  String toString() => 'ForeignBackupException';
}

/// The backup was written by a newer app than this one.
class UnsupportedBackupVersionException implements Exception {
  const UnsupportedBackupVersionException(this.version);

  final int version;

  @override
  String toString() => 'UnsupportedBackupVersionException($version)';
}

class BackupRecord {
  const BackupRecord({
    required this.poolType,
    required this.time,
    required this.name,
    required this.resourceType,
    required this.resourceId,
    required this.rarity,
    required this.count,
    required this.recordIndex,
  });

  factory BackupRecord.fromJson(Map<String, dynamic> json) => BackupRecord(
    poolType: (json['pool'] as num).toInt(),
    time: json['time'] as String,
    name: json['name'] as String,
    resourceType: json['resource_type'] as String? ?? '',
    resourceId: (json['resource_id'] as num?)?.toInt() ?? 0,
    rarity: (json['rarity'] as num).toInt(),
    count: (json['count'] as num?)?.toInt() ?? 1,
    recordIndex: (json['index'] as num).toInt(),
  );

  final int poolType;

  /// Server wall-clock time, formatted like the API (`yyyy-MM-dd HH:mm:ss`).
  final String time;
  final String name;
  final String resourceType;
  final int resourceId;
  final int rarity;
  final int count;

  /// Position among records of the pool sharing the same [time].
  final int recordIndex;

  Map<String, dynamic> toJson() => {
    'pool': poolType,
    'time': time,
    'name': name,
    'resource_type': resourceType,
    'resource_id': resourceId,
    'rarity': rarity,
    'count': count,
    'index': recordIndex,
  };
}

class BackupAccount {
  const BackupAccount({
    required this.uid,
    required this.serverId,
    required this.records,
    this.alias,
  });

  factory BackupAccount.fromJson(Map<String, dynamic> json) {
    final alias = json['alias'];
    return BackupAccount(
      uid: json['uid'] as String,
      serverId: json['server_id'] as String? ?? '',
      alias: alias is String && alias.trim().isNotEmpty ? alias.trim() : null,
      records: [
        for (final r in json['records'] as List<dynamic>)
          BackupRecord.fromJson(r as Map<String, dynamic>),
      ],
    );
  }

  final String uid;

  /// Empty when unknown (e.g. imported from another platform); a later URL
  /// import fills it in.
  final String serverId;
  final String? alias;
  final List<BackupRecord> records;

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'server_id': serverId,
    if (alias != null) 'alias': alias,
    'records': [for (final r in records) r.toJson()],
  };
}

/// Accounts and their records, as written to and read from a backup file.
class BackupBundle {
  const BackupBundle({
    required this.exportedAt,
    required this.appVersion,
    required this.accounts,
  });

  factory BackupBundle.fromJson(Map<String, dynamic> json) {
    final version = json['schema_version'];
    if (version is! int) throw const FormatException('schema_version');
    if (version > backupSchemaVersion) {
      throw UnsupportedBackupVersionException(version);
    }
    final raw = json['accounts'];
    if (raw is! List) throw const FormatException('accounts');
    final accounts = <BackupAccount>[];
    final seen = <String>{};
    for (final entry in raw) {
      final account = BackupAccount.fromJson(entry as Map<String, dynamic>);
      if (!seen.add(account.uid)) {
        throw FormatException('duplicate uid ${account.uid}');
      }
      accounts.add(account);
    }
    return BackupBundle(
      exportedAt:
          DateTime.tryParse(json['exported_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
      appVersion: json['app_version'] as String? ?? '',
      accounts: accounts,
    );
  }

  final DateTime exportedAt;
  final String appVersion;
  final List<BackupAccount> accounts;

  int get recordCount => accounts.fold(0, (n, a) => n + a.records.length);

  Map<String, dynamic> toJson() => {
    'schema_version': backupSchemaVersion,
    'app': backupAppId,
    'exported_at': exportedAt.toUtc().toIso8601String(),
    'app_version': appVersion,
    'accounts': [for (final a in accounts) a.toJson()],
  };

  String encode() => const JsonEncoder.withIndent(' ').convert(toJson());
}
