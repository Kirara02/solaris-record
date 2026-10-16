import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_sliver_header.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../update/domain/update_platform.dart';
import '../../update/presentation/update_actions.dart';
import '../../update/presentation/update_dialog.dart';
import '../../update/update_providers.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  bool _checking = false;

  /// Asks GitHub for a newer release and says what it found. Unlike the
  /// automatic check it also offers a version the user skipped.
  Future<void> _checkNow() async {
    final t = context.t;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _checking = true);
    final result = await checkForUpdate(ref, manual: true);
    if (!mounted) return;
    setState(() => _checking = false);
    switch (result) {
      case UpdateAvailable():
        await showUpdateDialog(context, result);
      case UpdateUpToDate():
        messenger.showSnackBar(SnackBar(content: Text(t.update.upToDate)));
      case UpdateCheckFailed():
        messenger.showSnackBar(SnackBar(content: Text(t.update.checkFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppSliverHeader(title: t.about.title, showBack: true),
          SliverAdaptivePadding(
            sliver: SliverList.list(
              children: [
                const SizedBox(height: 8),
                SettingsGroup(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const AppLogo(size: 88),
                          const SizedBox(height: 16),
                          Text(
                            t.appName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder: (context, snapshot) => Text(
                              snapshot.hasData
                                  ? t.about.version(
                                      version: snapshot.data!.version,
                                    )
                                  : '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.about.description,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (updatesSupported) ...[
                  SettingsSectionHeader(title: t.update.sectionUpdates),
                  SettingsGroup(
                    children: [
                      SettingsSwitchItem(
                        icon: Icons.autorenew,
                        title: t.update.autoTitle,
                        subtitle: t.update.autoSubtitle,
                        value: ref.watch(autoUpdateCheckProvider),
                        onChanged: ref
                            .read(autoUpdateCheckProvider.notifier)
                            .set,
                      ),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) => SettingsItem(
                          icon: Icons.system_update_outlined,
                          title: t.update.checkTitle,
                          subtitle: _checking
                              ? t.update.checking
                              : snapshot.hasData
                              ? t.update.checkSubtitle(
                                  version: snapshot.data!.version,
                                )
                              : null,
                          showDivider: false,
                          trailing: _checking
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: M3EProgressIndicator.circular(
                                    strokeWidth: 2,
                                  ),
                                )
                              : null,
                          onTap: _checking ? null : _checkNow,
                        ),
                      ),
                    ],
                  ),
                ],
                SettingsSectionHeader(title: t.about.sectionInfo),
                SettingsGroup(
                  children: [
                    SettingsItem(
                      icon: Icons.cloud_download_outlined,
                      title: t.about.sourceTitle,
                      subtitle: t.about.sourceBody,
                    ),
                    SettingsItem(
                      icon: Icons.gavel,
                      title: t.about.disclaimerTitle,
                      subtitle: t.about.disclaimerBody,
                    ),
                    SettingsItem(
                      icon: Icons.description_outlined,
                      title: t.about.licensesTitle,
                      subtitle: t.about.licensesBody,
                      showDivider: false,
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: t.appName,
                        applicationIcon: const Padding(
                          padding: EdgeInsets.all(8),
                          child: AppLogo(size: 56),
                        ),
                      ),
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
