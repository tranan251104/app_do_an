class Transaction {
  final String title;
  final int amount;
  final String time;

  Transaction({
    required this.title,
    required this.amount,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        "title": title,
        "amount": amount,
        "time": time,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      title: json["title"],
      amount: json["amount"],
      time: json["time"],
    );
  }
}
