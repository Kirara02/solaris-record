import 'package:url_launcher/url_launcher.dart';

/// Opens links in the user's browser. A class (not a bare function) so tests
/// can substitute it through a provider.
class UrlOpener {
  const UrlOpener();

  /// True when the link was handed to the system.
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}
