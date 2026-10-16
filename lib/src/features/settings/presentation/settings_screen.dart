import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/routing/app_router.dart';
import '../../../shared/widgets/app_sliver_header.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../import/presentation/import_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppSliverHeader(title: t.settings.title),
          SliverAdaptivePadding(
            sliver: SliverList.list(
              children: [
                const SizedBox(height: 8),
                SettingsGroup(
                  children: [
                    SettingsItem(
                      icon: Icons.download_outlined,
                      title: t.settings.import,
                      subtitle: t.settings.importSubtitle,
                      onTap: () => showImportDialog(context),
                    ),
                    SettingsItem(
                      icon: Icons.people_outline,
                      title: t.settings.accounts,
                      subtitle: t.settings.accountsSubtitle,
                      onTap: () => context.go(AppRoutes.accounts),
                    ),
                    SettingsItem(
                      icon: Icons.palette_outlined,
                      title: t.settings.appearance,
                      subtitle: t.settings.appearanceSubtitle,
                      onTap: () => context.go(AppRoutes.appearance),
                    ),
                    SettingsItem(
                      icon: Icons.storage_outlined,
                      title: t.settings.data,
                      subtitle: t.settings.dataSubtitle,
                      onTap: () => context.go(AppRoutes.data),
                    ),
                    SettingsItem(
                      icon: Icons.info_outline,
                      title: t.settings.about,
                      subtitle: t.settings.aboutSubtitle,
                      showDivider: false,
                      onTap: () => context.go(AppRoutes.about),
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
