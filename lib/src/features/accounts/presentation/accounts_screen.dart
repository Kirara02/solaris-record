import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/providers.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/widgets/app_sliver_header.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../import/presentation/import_dialog.dart';
import '../../import/saved_import_urls.dart';
import '../accounts_providers.dart';
import '../domain/account.dart';
import 'account_widgets.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final accounts = ref.watch(accountsProvider).value ?? const <Account>[];
    final active = ref.watch(activeAccountProvider);

    if (accounts.isEmpty) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            AppSliverHeader(title: t.accounts.title, showBack: true),
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.people_outline,
                title: t.accounts.emptyTitle,
                body: t.accounts.empty,
                action: M3EButton(
                  size: M3EButtonSize.md,
                  icon: const Icon(Icons.download),
                  label: Text(t.accounts.addAccount),
                  onPressed: () => showImportDialog(context),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppSliverHeader(title: t.accounts.title, showBack: true),
          SliverAdaptivePadding(
            sliver: SliverList.list(
              children: [
                SettingsSectionHeader(title: t.accounts.sectionPrivacy),
                SettingsGroup(
                  children: [
                    SettingsSwitchItem(
                      icon: Icons.visibility_off_outlined,
                      title: t.accounts.maskUid,
                      subtitle: t.accounts.maskUidSubtitle,
                      value: ref.watch(maskUidProvider),
                      onChanged: ref.read(maskUidProvider.notifier).set,
                      showDivider: false,
                    ),
                  ],
                ),
                SettingsSectionHeader(title: t.accounts.sectionAll),
                SettingsGroup(
                  children: [
                    for (final (i, a) in accounts.indexed)
                      _AccountTile(
                        account: a,
                        selected: a.uid == active?.uid,
                        showDivider: i != accounts.length - 1,
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

class _AccountTile extends ConsumerWidget {
  const _AccountTile({
    required this.account,
    required this.selected,
    required this.showDivider,
  });

  final Account account;
  final bool selected;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    return SettingsItem(
      showDivider: showDivider,
      leading: AccountAvatar(account: account),
      title: accountName(t, account),
      subtitle: t.accounts.uid(uid: displayUid(ref, account.uid)),
      onTap: () => ref.read(activeUidProvider.notifier).select(account.uid),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected)
            StatusBadge(
              label: t.accounts.active,
              background: scheme.primaryContainer,
              foreground: scheme.onPrimaryContainer,
            ),
          IconButton(
            tooltip: t.accounts.actions,
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showActions(context, ref),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet with the account's actions (edit alias / delete).
  Future<void> _showActions(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                accountName(t, account),
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SettingsGroup(
                children: [
                  SettingsItem(
                    icon: Icons.edit_outlined,
                    title: t.accounts.editAlias,
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      final alias = await _askAlias(context, account.alias);
                      if (alias != null) {
                        await ref
                            .read(conveneRepositoryProvider)
                            .setAlias(account.uid, alias);
                      }
                    },
                  ),
                  SettingsItem(
                    icon: Icons.delete_outline,
                    iconColor: scheme.error,
                    title: t.accounts.delete,
                    titleStyle: Theme.of(sheetContext).textTheme.bodyLarge
                        ?.copyWith(color: scheme.error),
                    showDivider: false,
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      final ok = await showConfirmDialog(
                        context,
                        title: t.accounts.deleteTitle,
                        body: t.accounts.deleteBody(
                          uid: displayUid(ref, account.uid),
                        ),
                        confirmLabel: t.accounts.delete,
                        cancelLabel: t.accounts.cancel,
                      );
                      if (!ok) return;
                      await ref
                          .read(conveneRepositoryProvider)
                          .deleteAccount(account.uid);
                      await ref
                          .read(savedImportUrlsProvider)
                          .remove(account.uid);
                      if (selected) {
                        await ref.read(activeUidProvider.notifier).select(null);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<String?> _askAlias(BuildContext context, String? current) =>
      showDialog<String>(
        context: context,
        builder: (context) => _AliasDialog(initial: current),
      );
}

/// Owns its controller so it is disposed with the dialog's own lifecycle.
class _AliasDialog extends StatefulWidget {
  const _AliasDialog({this.initial});

  final String? initial;

  @override
  State<_AliasDialog> createState() => _AliasDialogState();
}

class _AliasDialogState extends State<_AliasDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(t.accounts.editAlias),
      content: AppTextField(
        controller: _controller,
        autofocus: true,
        label: t.accounts.alias,
        textInputAction: TextInputAction.done,
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.accounts.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(t.accounts.save),
        ),
      ],
    );
  }
}
