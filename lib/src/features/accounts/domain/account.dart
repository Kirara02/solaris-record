class Account {
  const Account({
    required this.uid,
    required this.serverId,
    required this.number,
    this.alias,
  });

  final String uid;
  final String serverId;
  final String? alias;

  /// 1-based order in which the account was added; names it "Account N" while
  /// it has no alias.
  final int number;
}
