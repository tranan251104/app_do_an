// Thong tin hien thi ket qua chuyen tien neu chuyen tien cho nguoi co tai khoan ngan hang
class BankAccount1 {
  final String bankName;
  final String accountNumber;
  final String ownerName;

  BankAccount1({
    required this.bankName,
    required this.accountNumber,
    required this.ownerName,
  });

  Map<String, dynamic> toJson() => {
        "bankName": bankName,
        "accountNumber": accountNumber,
        "ownerName": ownerName,
      };

  factory BankAccount1.fromJson(Map<String, dynamic> json) {
    return BankAccount1(
      bankName: json["bankName"],
      accountNumber: json["accountNumber"],
      ownerName: json["ownerName"],
    );
  }
}
