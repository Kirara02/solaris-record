import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_sliver_header.dart';
import '../../../shared/widgets/settings_group.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
