import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/update_info.dart';

final _log = Logger('update');

/// The GitHub repository releases are published to.
const githubRepo = 'Kirara02/solaris-record';

class UpdateException implements Exception {
  const UpdateException(this.message);

  final String message;

  @override
  String toString() => 'UpdateException($message)';
}

/// Looks up and downloads releases of the app from GitHub.
///
/// The releases are the ones the release workflow publishes for each version
/// tag, so a new tag shows up here once its release is out.
class UpdateService {
  UpdateService(this._dio);

  final Dio _dio;

  static const _releaseHost = 'https://github.com/$githubRepo/releases/';

  /// The latest stable release (GitHub leaves out drafts and pre-releases), or
  /// null when the repository has none yet. [platform] picks which file is
  /// offered (see `updatePlatform`).
  Future<UpdateInfo?> fetchLatest(String platform) =>
      _fetchRelease('latest', platform);

  /// The release published for [version], or null when there is none (for
  /// example a build that was never tagged).
  Future<UpdateInfo?> fetchVersion(String version, String platform) =>
      _fetchRelease('tags/v$version', platform);

  Future<UpdateInfo?> _fetchRelease(String path, String platform) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(
        'https://api.github.com/repos/$githubRepo/releases/$path',
        options: Options(
          headers: {'Accept': 'application/vnd.github+json'},
          validateStatus: (s) => s != null && s < 500,
        ),
      );
    } on DioException catch (e) {
      throw UpdateException('network: ${e.message}');
    }
    if (response.statusCode == 404) return null;
    final data = response.data;
    if (response.statusCode != 200 || data is! Map<String, dynamic>) {
      throw UpdateException('GitHub answered ${response.statusCode}');
    }

    final tag = (data['tag_name'] as String? ?? '').trim();
    if (tag.isEmpty) return null;
    final assets = [
      for (final a in (data['assets'] as List?) ?? const [])
        if (a is Map<String, dynamic>) ?_parseAsset(a),
    ];
    return UpdateInfo(
      version: tag.replaceFirst(RegExp(r'^[vV]'), ''),
      notes: data['body'] as String? ?? '',
      pageUrl:
          data['html_url'] as String? ??
          'https://github.com/$githubRepo/releases',
      publishedAt: DateTime.tryParse(data['published_at'] as String? ?? ''),
      asset: pickAsset(assets, platform),
    );
  }

  /// Only files served from this repository's own releases are accepted.
  UpdateAsset? _parseAsset(Map<String, dynamic> json) {
    final name = json['name'] as String?;
    final url = json['browser_download_url'] as String?;
    if (name == null || url == null || !url.startsWith(_releaseHost)) {
      return null;
    }
    final digest = (json['digest'] as String? ?? '').toLowerCase().replaceFirst(
      'sha256:',
      '',
    );
    return UpdateAsset(
      name: name,
      url: url,
      sha256: RegExp(r'^[a-f0-9]{64}$').hasMatch(digest) ? digest : null,
      size: (json['size'] as num?)?.toInt() ?? 0,
    );
  }

  /// Where downloaded updates are kept.
  Future<Directory> updateDirectory() async {
    final base =
        await getExternalStorageDirectory() ?? await getTemporaryDirectory();
    return Directory('${base.path}${Platform.pathSeparator}updates');
  }

  /// Downloads [asset] and checks it against its published SHA-256; a file that
  /// doesn't match is deleted and reported as an error. Returns the file.
  Future<File> download(
    UpdateAsset asset, {
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final expected = asset.sha256;
    if (expected == null) {
      throw const UpdateException('the release has no checksum for this file');
    }
    final dir = await updateDirectory();
    await dir.create(recursive: true);
    final file = File('${dir.path}${Platform.pathSeparator}${asset.name}');
    final part = File('${file.path}.part');
    _log.info('Downloading update file=${asset.name} bytes=${asset.size}');
    try {
      await _dio.download(
        asset.url,
        part.path,
        onReceiveProgress: onProgress,
        cancelToken: cancelToken,
        options: Options(receiveTimeout: const Duration(minutes: 2)),
      );
      final actual = (await sha256.bind(part.openRead()).first).toString();
      if (actual != expected) {
        throw const UpdateException('checksum mismatch');
      }
      if (await file.exists()) await file.delete();
      await part.rename(file.path);
      _log.info('Update downloaded and verified file=${asset.name}');
      return file;
    } on Object {
      if (await part.exists()) await part.delete();
      rethrow;
    }
  }

  /// Hands the downloaded APK to the system installer.
  Future<bool> openInstaller(File file) async {
    final result = await OpenFilex.open(
      file.path,
      type: 'application/vnd.android.package-archive',
    );
    _log.info('Installer opened result=${result.type.name}');
    return result.type == ResultType.done;
  }

  /// Deletes downloaded updates, e.g. once the app has been updated.
  Future<void> clearDownloads() async {
    try {
      final dir = await updateDirectory();
      if (await dir.exists()) await dir.delete(recursive: true);
    } on Object catch (e) {
      _log.fine('Could not clear old updates: $e');
    }
  }
}
