import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// The two hosts encore.moe serves its game images from. A file that one of
/// them lacks is often on the other: the missing one answers 200 with an HTML
/// page instead of a 404, which the image decoder then rejects.
const _encoreHosts = ['api-v2.encore.moe', 'api.encore.moe'];

const _imageExtensions = {'.webp', '.png', '.jpg', '.jpeg', '.gif', '.bmp'};

/// Where to look for an encore.moe image, best guess first; just [url] for
/// anything else.
///
/// Whimpering Wastes sends its images as
/// `api-v2.encore.moe/api/resource/Data/….png`, a path that serves HTML. The
/// same file is at `api.encore.moe/resource/Data/….webp`, so that comes first.
/// Otherwise the other host is the fallback.
List<String> encoreImageCandidates(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !_isImageUrl(url)) return [url];
  final i = _encoreHosts.indexOf(uri.host);
  if (i < 0) return [url];
  final mirror = uri.replace(host: _encoreHosts[1 - i]).toString();
  if (uri.path.startsWith('/api/resource/')) {
    final legacy = uri.replace(
      host: 'api.encore.moe',
      path: uri.path
          .replaceFirst('/api/resource/', '/resource/')
          .replaceFirst(RegExp(r'\.png$', caseSensitive: false), '.webp'),
    );
    return [legacy.toString(), url];
  }
  return [url, mirror];
}

bool _isImageUrl(String url) {
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
  return _imageExtensions.any(path.endsWith);
}

bool _looksLikeImage(FileServiceResponse response) =>
    response.statusCode == 200 &&
    _imageExtensions.contains(response.fileExtension.toLowerCase());

/// Fetches like [HttpFileService], but for an encore.moe image that comes back
/// as something other than an image, tries the other places the file may be
/// (see [encoreImageCandidates]).
class EncoreFallbackFileService extends FileService {
  EncoreFallbackFileService({FileService? inner})
    : _inner = inner ?? HttpFileService();

  final FileService _inner;

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    final candidates = encoreImageCandidates(url);
    if (candidates.length == 1) return _inner.get(url, headers: headers);
    FileServiceResponse? firstAnswer;
    for (final candidate in candidates) {
      try {
        final response = await _inner.get(candidate, headers: headers);
        if (_looksLikeImage(response)) {
          await firstAnswer?.content.drain<void>();
          return response;
        }
        if (firstAnswer == null) {
          firstAnswer = response;
        } else {
          await response.content.drain<void>();
        }
      } on Object {
        // Try the next place.
      }
    }
    // None of them is an image: report what the first one said.
    return firstAnswer ?? _inner.get(url, headers: headers);
  }
}

/// The disk cache of every network image. It shares the default store, so
/// "clear image cache" and the storage figure keep covering it.
class AppImageCache extends CacheManager {
  AppImageCache._()
    : super(
        Config(
          DefaultCacheManager.key,
          fileService: EncoreFallbackFileService(),
        ),
      );

  static final instance = AppImageCache._();
}
