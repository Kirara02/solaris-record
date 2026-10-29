import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../data/providers.dart';
import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/content_dialog.dart';
import '../../../shared/layout/window_size.dart';
import '../../../shared/theme/mornye_icons.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_dialog.dart';
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
            SliverFillBody(
              child: EmptyState(
                icon: Icons.people_outline,
                title: t.accounts.emptyTitle,
                body: t.accounts.empty,
                action: AppButton(
                  icon: const AdaptiveIcon(Icons.download),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                  child: Text(
                    t.accounts.reorderHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                _AccountList(accounts: accounts, activeUid: active?.uid),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The reorderable list of accounts. Shows the dragged order right away and
/// drops it once the database stream delivers the saved one.
class _AccountList extends ConsumerStatefulWidget {
  const _AccountList({required this.accounts, required this.activeUid});

  final List<Account> accounts;
  final String? activeUid;

  @override
  ConsumerState<_AccountList> createState() => _AccountListState();
}

class _AccountListState extends ConsumerState<_AccountList> {
  List<Account>? _pending;

  @override
  void didUpdateWidget(_AccountList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accounts != widget.accounts) _pending = null;
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final list = [...(_pending ?? widget.accounts)];
    if (newIndex == oldIndex) return;
    list.insert(newIndex, list.removeAt(oldIndex));
    setState(() => _pending = list);
    await ref.read(conveneRepositoryProvider).reorderAccounts([
      for (final a in list) a.uid,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = _pending ?? widget.accounts;
    return SettingsGroup(
      children: [
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: _onReorder,
          children: [
            for (final (i, a) in accounts.indexed)
              _AccountTile(
                key: ValueKey(a.uid),
                index: i,
                account: a,
                selected: a.uid == widget.activeUid,
                showDivider: i != accounts.length - 1,
              ),
          ],
        ),
      ],
    );
  }
}

class _AccountTile extends ConsumerWidget {
  const _AccountTile({
    super.key,
    required this.index,
    required this.account,
    required this.selected,
    required this.showDivider,
  });

  final int index;
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
            icon: const AdaptiveIcon(Icons.more_vert),
            onPressed: () => _showActions(context, ref),
          ),
          ReorderableDragStartListener(
            index: index,
            child: Tooltip(
              message: t.accounts.dragHandle,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: AdaptiveIcon(
                  Icons.drag_handle,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sheet (dialog on wide windows) with the account's actions (edit alias / delete).
  Future<void> _showActions(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    return showAdaptiveSheet(
      context,
      (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                    await ref.read(savedImportUrlsProvider).remove(account.uid);
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
    return AppAlertDialog(
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
