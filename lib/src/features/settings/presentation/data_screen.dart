import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/providers.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/widgets/app_sliver_header.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../accounts/accounts_providers.dart';
import '../../backup/presentation/backup_actions.dart';
import '../../import/saved_import_urls.dart';
import '../data/storage_usage.dart';
import '../settings_providers.dart';
import 'log_actions.dart';

class DataScreen extends ConsumerWidget {
  const DataScreen({super.key});

  Future<void> _clearImages(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final messenger = ScaffoldMessenger.of(context);
    final bytes = ref.read(storageUsageProvider).value?.imageCacheBytes;
    final confirmed = await showConfirmDialog(
      context,
      title: t.data.clearImagesTitle,
      body: bytes == null
          ? t.data.clearImagesBody
          : t.data.clearImagesBodySize(size: formatBytes(bytes)),
      confirmLabel: t.data.clear,
      cancelLabel: t.data.cancel,
    );
    if (!confirmed) return;
    await DefaultCacheManager().emptyCache();
    await ref.read(itemImageServiceProvider).clearCachedUrls();
    ref.invalidate(storageUsageProvider);
    messenger.showSnackBar(SnackBar(content: Text(t.data.imagesCleared)));
  }

  Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: t.data.deleteAllTitle,
      body: t.data.deleteAllBody,
      confirmLabel: t.data.confirm,
      cancelLabel: t.data.cancel,
    );
    if (!confirmed) return;
    await ref.read(conveneRepositoryProvider).deleteAllData();
    await ref.read(savedImportUrlsProvider).clear();
    await ref.read(activeUidProvider.notifier).select(null);
    ref.invalidate(storageUsageProvider);
    messenger.showSnackBar(SnackBar(content: Text(t.data.deleted)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    final usage = ref.watch(storageUsageProvider);
    String size(int Function(StorageUsage) pick) => usage.maybeWhen(
      data: (u) => formatBytes(pick(u)),
      orElse: () => t.data.calculating,
    );
    final valueStyle = Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontWeight: FontWeight.w700);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppSliverHeader(title: t.data.title, showBack: true),
          SliverAdaptivePadding(
            sliver: SliverList.list(
              children: [
                SettingsSectionHeader(title: t.data.sectionUsage),
                SettingsGroup(
                  children: [
                    SettingsItem(
                      icon: Icons.storage_outlined,
                      title: t.data.database,
                      subtitle: usage.whenOrNull(
                        data: (u) => t.data.databaseDetail(
                          records: u.records,
                          accounts: u.accounts,
                        ),
                      ),
                      trailing: Text(
                        size((u) => u.databaseBytes),
                        style: valueStyle,
                      ),
                    ),
                    SettingsItem(
                      icon: Icons.image_outlined,
                      title: t.data.imageCache,
                      trailing: Text(
                        size((u) => u.imageCacheBytes),
                        style: valueStyle,
                      ),
                    ),
                    SettingsItem(
                      icon: Icons.pie_chart_outline,
                      title: t.data.total,
                      showDivider: false,
                      trailing: Text(
                        size((u) => u.totalBytes),
                        style: valueStyle?.copyWith(color: scheme.primary),
                      ),
                    ),
                  ],
                ),
                SettingsSectionHeader(title: t.data.sectionBackup),
                SettingsGroup(
                  children: [
                    SettingsItem(
                      icon: Icons.upload_file_outlined,
                      title: t.data.export,
                      subtitle: t.data.exportSubtitle,
                      onTap: () => exportBackup(context, ref),
                    ),
                    SettingsItem(
                      icon: Icons.file_open_outlined,
                      title: t.data.import,
                      subtitle: t.data.importSubtitle,
                      showDivider: false,
                      onTap: () => importBackup(context, ref),
                    ),
                  ],
                ),
                SettingsSectionHeader(title: t.data.sectionCache),
                SettingsGroup(
                  children: [
                    SettingsItem(
                      icon: Icons.image_outlined,
                      title: t.data.clearImages,
                      subtitle: t.data.clearImagesSubtitle,
                      showDivider: false,
                      onTap: () => _clearImages(context, ref),
                    ),
                  ],
                ),
                SettingsSectionHeader(title: t.data.sectionLogs),
                SettingsGroup(
                  children: [
                    SettingsItem(
                      icon: Icons.bug_report_outlined,
                      title: t.data.exportLogs,
                      subtitle: ref
                          .watch(logSizeProvider)
                          .maybeWhen(
                            data: (bytes) =>
                                t.data.logsSize(size: formatBytes(bytes)),
                            orElse: () => t.data.logsHint,
                          ),
                      onTap: () => exportLogs(context, ref),
                    ),
                    SettingsItem(
                      icon: Icons.cleaning_services_outlined,
                      title: t.data.clearLogs,
                      subtitle: t.data.logsHint,
                      showDivider: false,
                      onTap: () => clearLogs(context, ref),
                    ),
                  ],
                ),
                SettingsSectionHeader(title: t.data.sectionRecords),
                SettingsGroup(
                  children: [
                    SettingsItem(
                      icon: Icons.delete_outline,
                      iconColor: scheme.error,
                      title: t.data.deleteAll,
                      titleStyle: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: scheme.error),
                      subtitle: t.data.deleteAllSubtitle,
                      showDivider: false,
                      onTap: () => _deleteAll(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
