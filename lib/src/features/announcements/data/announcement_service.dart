import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../../update/data/update_service.dart';
import '../domain/announcement.dart';

final _log = Logger('announcements');

/// Reads `announcements.json` from the repository's default branch. The file
/// is public and static; nothing about the user or the device is sent.
class AnnouncementService {
  AnnouncementService(this._dio);

  final Dio _dio;

  static const url =
      'https://raw.githubusercontent.com/$githubRepo/main/announcements.json';

  /// Every announcement in the file, or an empty list when it is missing or
  /// can't be read.
  Future<List<Announcement>> fetch() async {
    try {
      final response = await _dio.get<dynamic>(
        url,
        options: Options(
          responseType: ResponseType.json,
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      if (response.statusCode != 200) {
        _log.info('No announcements file (${response.statusCode})');
        return const [];
      }
      return parseAnnouncements(response.data);
    } on Object catch (e) {
      _log.info('Could not load announcements: $e');
      return const [];
    }
  }
}
