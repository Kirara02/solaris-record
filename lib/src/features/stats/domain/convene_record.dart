class ConveneRecord {
  const ConveneRecord({
    required this.uid,
    required this.poolType,
    required this.time,
    required this.name,
    required this.resourceType,
    required this.rarity,
    required this.count,
    required this.recordIndex,
    this.resourceId = 0,
  });

  final String uid;
  final int poolType;
  final String time;
  final String name;
  final String resourceType;
  final int rarity;
  final int count;
  final int recordIndex;
  final int resourceId;
}
