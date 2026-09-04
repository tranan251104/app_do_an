class Promotion {
  final String id;
  final String iconKey;
  final String brand;
  final String description;
  final String note;
  final String category;
  final DateTime createdAt;
  final DateTime validUntil;

  const Promotion({
    required this.id,
    required this.iconKey,
    required this.brand,
    required this.description,
    required this.note,
    required this.category,
    required this.createdAt,
    required this.validUntil,
  });

  bool isActiveAt(DateTime time) => !validUntil.isBefore(time);

  bool isExpiringSoonAt(DateTime time, {int withinDays = 20}) {
    final remainingDays = remainingDaysAt(time);
    return isActiveAt(time) && remainingDays <= withinDays;
  }

  int remainingDaysAt(DateTime time) {
    final today = DateTime(time.year, time.month, time.day);
    final expiryDate = DateTime(
      validUntil.year,
      validUntil.month,
      validUntil.day,
    );
    return expiryDate.difference(today).inDays;
  }
}
