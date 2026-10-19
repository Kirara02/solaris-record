import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/i18n/gen/strings.g.dart';

final _log = Logger('update');

/// A downloaded update the user has been told about.
class PendingUpdate {
  const PendingUpdate({required this.version, required this.path});

  final String version;
  final String path;
}

/// Android only. While an update downloads it shows the progress in a
/// foreground-service notification (so the download keeps going when the
/// screen turns off); when it finishes, a notification with a sound tells the
/// user the update is ready, and another says so if the download failed. The
/// ready notification is taken away once the update has been installed.
///
/// Tapping the notification opens the installer for the downloaded file. The
/// notification is removed when the new version is running (see
/// `UpdateStartupCheck`) and, without waiting for a launch, by the native
/// `PackageReplacedReceiver`, which cancels [notificationId].
class UpdateNotifier {
  UpdateNotifier({required this._prefs, required this._openInstaller});

  /// The ready / failed notification. Shared with `PackageReplacedReceiver.kt`.
  static const notificationId = 7001;

  /// The download progress, shown by the foreground service.
  static const _progressId = 7002;

  static const _channelId = 'app_update';
  static const _progressChannelId = 'app_update_progress';
  static const _icon = 'ic_launcher_monochrome';
  static const _versionKey = 'pending_update_version';
  static const _pathKey = 'pending_update_path';

  final SharedPreferences _prefs;
  final Future<bool> Function(File file) _openInstaller;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool _serviceRunning = false;
  int _lastPercent = -1;

  /// The update that was downloaded but not installed yet, if any.
  PendingUpdate? get pending {
    final version = _prefs.getString(_versionKey);
    final path = _prefs.getString(_pathKey);
    return version == null || path == null
        ? null
        : PendingUpdate(version: version, path: path);
  }

  Future<void> _init() async {
    if (_ready) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_icon),
      ),
      onDidReceiveNotificationResponse: (response) {
        final path = response.payload;
        if (path != null) _install(path);
      },
    );
    _ready = true;
  }

  Future<void> _install(String path) async {
    final file = File(path);
    if (!await file.exists()) return;
    await _openInstaller(file);
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  AndroidNotificationDetails _progressDetails(int percent) =>
      AndroidNotificationDetails(
        _progressChannelId,
        t.update.notifProgressChannel,
        channelDescription: t.update.notifProgressChannelDesc,
        icon: _icon,
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        maxProgress: 100,
        progress: percent,
        indeterminate: percent < 0,
        ongoing: true,
        onlyAlertOnce: true,
        playSound: false,
        enableVibration: false,
      );

  /// Starts the foreground service with the progress notification, so the
  /// download survives the screen turning off. Asks for the notification
  /// permission first (Android 13+); without it the download simply runs
  /// without a notification.
  Future<void> beginDownload(String version) async {
    if (!Platform.isAndroid) return;
    try {
      await _init();
      if (await _android?.requestNotificationsPermission() == false) return;
      _lastPercent = -1;
      await _android?.startForegroundService(
        id: _progressId,
        title: t.update.notifDownloading(version: version),
        notificationDetails: _progressDetails(-1),
        startType: AndroidServiceStartType.startNotSticky,
        foregroundServiceTypes: {
          AndroidServiceForegroundType.foregroundServiceTypeDataSync,
        },
      );
      _serviceRunning = true;
    } on Object catch (e, st) {
      _log.warning('Could not start the download notification', e, st);
    }
  }

  /// Updates the progress notification (only when the percentage changes).
  Future<void> downloadProgress(String version, int received, int total) async {
    if (!_serviceRunning || total <= 0) return;
    final percent = received * 100 ~/ total;
    if (percent == _lastPercent) return;
    _lastPercent = percent;
    String mb(int bytes) => (bytes / 1048576).toStringAsFixed(1);
    try {
      await _plugin.show(
        id: _progressId,
        title: t.update.notifDownloading(version: version),
        body: t.update.notifProgress(
          received: mb(received),
          total: mb(total),
          percent: percent,
        ),
        notificationDetails: NotificationDetails(
          android: _progressDetails(percent),
        ),
      );
    } on Object catch (e) {
      _log.fine('Could not update the progress notification: $e');
    }
  }

  /// Stops the service and removes the progress notification.
  Future<void> endDownload() async {
    if (!_serviceRunning) return;
    _serviceRunning = false;
    try {
      await _android?.stopForegroundService();
      await _plugin.cancel(id: _progressId);
    } on Object catch (e) {
      _log.fine('Could not stop the download notification: $e');
    }
  }

  /// Tells the user, with a sound, that the download failed.
  Future<void> showFailed() async {
    if (!Platform.isAndroid) return;
    try {
      await _init();
      if (await _android?.requestNotificationsPermission() == false) return;
      await _plugin.show(
        id: notificationId,
        title: t.update.notifFailed,
        body: t.update.notifFailedBody,
        notificationDetails: NotificationDetails(android: _readyDetails()),
      );
    } on Object catch (e, st) {
      _log.warning('Could not show the update failure', e, st);
    }
  }

  AndroidNotificationDetails _readyDetails() => AndroidNotificationDetails(
    _channelId,
    t.update.notifChannel,
    channelDescription: t.update.notifChannelDesc,
    icon: _icon,
    importance: Importance.high,
    priority: Priority.high,
  );

  /// Posts the notification for the update [version] saved at [file]. Asks for
  /// the notification permission first (Android 13+); without it nothing is
  /// shown and the install flow carries on.
  Future<void> showDownloaded(String version, File file) async {
    if (!Platform.isAndroid) return;
    try {
      await _init();
      if (await _android?.requestNotificationsPermission() == false) {
        _log.info('Notification permission denied; no update notice');
        return;
      }
      await _prefs.setString(_versionKey, version);
      await _prefs.setString(_pathKey, file.path);
      await _plugin.show(
        id: notificationId,
        title: t.update.notifTitle,
        body: t.update.notifBody(version: version),
        payload: file.path,
        notificationDetails: NotificationDetails(android: _readyDetails()),
      );
      _log.info('Update notification shown version=$version');
    } on Object catch (e, st) {
      _log.warning('Could not show the update notification', e, st);
    }
  }

  /// Re-attaches the tap handler after a launch (the plugin must be set up in
  /// every process) and, when the launch itself came from tapping the
  /// notification, opens the installer.
  Future<void> restore() async {
    if (!Platform.isAndroid) return;
    try {
      await _init();
      final launch = await _plugin.getNotificationAppLaunchDetails();
      final path = launch?.notificationResponse?.payload;
      if (launch?.didNotificationLaunchApp == true && path != null) {
        await _install(path);
      }
    } on Object catch (e, st) {
      _log.warning('Could not restore the update notification', e, st);
    }
  }

  /// Removes the notification and forgets the pending update, once it has been
  /// installed or is no longer wanted.
  Future<void> dismiss() async {
    if (!Platform.isAndroid) return;
    try {
      await _init();
      await _plugin.cancel(id: notificationId);
    } on Object catch (e, st) {
      _log.warning('Could not remove the update notification', e, st);
    }
    await _prefs.remove(_versionKey);
    await _prefs.remove(_pathKey);
  }
}
