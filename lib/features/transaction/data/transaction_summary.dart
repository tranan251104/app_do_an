class TransactionSummary {
  final List<Map<String, dynamic>> transactions;
  final DateTime month;
  TransactionSummary(Iterable<Map<String, dynamic>> source, this.month)
    : transactions = source.where((tx) {
        final date = DateTime.tryParse(
          tx['createdAt']?.toString() ?? '',
        )?.toLocal();
        return tx['status']?.toString().toUpperCase() == 'COMPLETED' &&
            date != null &&
            date.year == month.year &&
            date.month == month.month &&
            const [
              'IN',
              'CREDIT',
              'OUT',
              'DEBIT',
            ].contains(tx['direction']?.toString().toUpperCase());
      }).toList();

  static bool incoming(Map<String, dynamic> tx) => const [
    'IN',
    'CREDIT',
  ].contains(tx['direction']?.toString().toUpperCase());
  static double amount(Map<String, dynamic> tx) =>
      (tx['amount'] as num? ?? 0).abs().toDouble();
  double get income =>
      transactions.where(incoming).fold(0, (sum, tx) => sum + amount(tx));
  double get expense => transactions
      .where((tx) => !incoming(tx))
      .fold(0, (sum, tx) => sum + amount(tx));
  Map<String, List<Map<String, dynamic>>> get groups {
    final result = <String, List<Map<String, dynamic>>>{};
    for (final tx in transactions) {
      (result[tx['type']?.toString() ?? 'OTHER'] ??= []).add(tx);
    }
    return result;
  }

  double daily(int day, bool isIncome) => transactions
      .where(
        (tx) =>
            incoming(tx) == isIncome &&
            DateTime.parse(tx['createdAt'].toString()).toLocal().day == day,
      )
      .fold(0, (sum, tx) => sum + amount(tx));
  static String typeLabel(String type) =>
      const {
        'INTERNAL_TRANSFER': 'Chuyển / nhận tiền AnPay',
        'LUCKY_MONEY': 'Lì xì cá nhân',
        'EXTERNAL_BANK_TRANSFER': 'Chuyển ngân hàng',
        'TOP_UP': 'Nạp tiền',
        'BILL_PAYMENT': 'Thanh toán hóa đơn',
        'PAYMENT': 'Thanh toán',
      }[type] ??
      'Giao dịch khác ($type)';
}
