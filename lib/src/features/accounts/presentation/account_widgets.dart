import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/i18n/gen/strings.g.dart';
import '../../../shared/layout/content_dialog.dart';
import '../../../shared/routing/app_routes.dart';
import '../../../shared/theme/app_tokens.dart';
import '../../../shared/widgets/settings_group.dart';
import '../accounts_providers.dart';
import '../domain/account.dart';

/// Circle with the first character of the account's display name.
class AccountAvatar extends StatelessWidget {
  const AccountAvatar({super.key, required this.account, this.radius = 20});

  final Account account;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      child: Text(
        account.alias?.characters.first.toUpperCase() ?? '${account.number}',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: radius * 0.9),
      ),
    );
  }
}

/// Sheet (dialog on wide windows) listing accounts; selecting one makes it active.
Future<void> showAccountSwitcher(BuildContext context, WidgetRef ref) {
  final accounts = ref.read(accountsProvider).value ?? const <Account>[];
  final activeUid = ref.read(activeAccountProvider)?.uid;
  final t = context.t;
  return showAdaptiveSheet(
    context,
    (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            t.accounts.switchTitle,
            style: Theme.of(sheetContext).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SettingsGroup(
            children: [
              for (final (i, a) in accounts.indexed)
                SettingsItem(
                  leading: AccountAvatar(account: a, radius: 16),
                  title: accountName(t, a),
                  subtitle: t.accounts.uid(uid: displayUid(ref, a.uid)),
                  showDivider: i != accounts.length - 1,
                  trailing: a.uid == activeUid
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(sheetContext).colorScheme.primary,
                        )
                      : const SizedBox.shrink(),
                  onTap: () {
                    ref.read(activeUidProvider.notifier).select(a.uid);
                    Navigator.pop(sheetContext);
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

/// "100······": the first three characters of a UID, the rest hidden, so
/// screenshots of the top bar don't expose it.
String maskUid(String uid) =>
    uid.length <= 3 ? uid : '${uid.substring(0, 3)}······';

/// Name to show for [account]: its alias, or "Account N" (N = the order it was
/// added in) while it has none.
String accountName(Translations t, Account account) =>
    account.alias ?? t.accounts.defaultName(n: account.number);

/// [uid] as the user wants to see it: masked unless they turned masking off.
/// Rebuilds the caller when the setting changes.
String displayUid(WidgetRef ref, String uid) =>
    ref.watch(maskUidProvider) ? maskUid(uid) : uid;

/// Account switcher for wide layouts: an outlined pill with the account's
/// icon, name and masked UID, opening a menu of accounts.
class AccountPill extends ConsumerWidget {
  const AccountPill({super.key, required this.account});

  final Account account;

  /// Value of the menu entry that opens the accounts screen.
  static const manageValue = '__manage__';

  /// Key of the pill, for tests.
  static const pillKey = ValueKey('account-pill');

  /// "Account 1 (100······)": the account's name and its UID.
  static String labelFor(Account account, Translations t, {bool mask = true}) {
    final shown = mask ? maskUid(account.uid) : account.uid;
    return '${accountName(t, account)} ($shown)';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accounts = ref.watch(accountsProvider).value ?? [account];
    final mask = ref.watch(maskUidProvider);
    String shown(String uid) => mask ? maskUid(uid) : uid;

    return PopupMenuButton<String>(
      tooltip: t.stats.switchAccount,
      offset: const Offset(0, 46),
      shape: RoundedRectangleBorder(
        borderRadius: context.tokens.borderRadiusControl,
      ),
      onSelected: (value) {
        if (value == manageValue) {
          context.go(AppRoutes.accounts);
        } else {
          ref.read(activeUidProvider.notifier).select(value);
        }
      },
      itemBuilder: (context) => [
        for (final a in accounts)
          PopupMenuItem<String>(
            value: a.uid,
            child: Row(
              children: [
                AccountAvatar(account: a, radius: 14),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        accountName(t, a),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        t.accounts.uid(uid: shown(a.uid)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (a.uid == account.uid)
                  Icon(Icons.check, size: 18, color: scheme.primary),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: manageValue,
          child: Row(
            children: [
              Icon(
                Icons.manage_accounts_outlined,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(t.stats.manageAccounts),
            ],
          ),
        ),
      ],
      child: Container(
        key: pillKey,
        height: 40,
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.only(left: 14, right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                labelFor(account, t, mask: mask),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, size: 20, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
