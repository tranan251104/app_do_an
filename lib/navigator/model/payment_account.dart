class PaymentAccount {
  final String accountNumber;
  final String name;      // ownerName hoặc serviceName
  final String provider;  // bankName hoặc provider (nhà cung cấp)
  final String? detail;   // Chi tiết dịch vụ (chỉ dùng cho isService = true)
  final bool isService;   // Để phân biệt chuyển khoản (false) và dịch vụ (true)

  PaymentAccount({
    required this.accountNumber,
    required this.name,
    required this.provider,
    this.detail,
    this.isService = false,
  });

  Map<String, dynamic> toJson() => {
        "accountNumber": accountNumber,
        "name": name,
        "provider": provider,
        "detail": detail,
        "isService": isService,
      };

  factory PaymentAccount.fromJson(Map<String, dynamic> json) {
    return PaymentAccount(
      accountNumber: json["accountNumber"],
      name: json["name"],
      provider: json["provider"],
      detail: json["detail"],
      isService: json["isService"] ?? false,
    );
  }

  // Helper để tạo từ BankAccount1 (Chuyển khoản)
  factory PaymentAccount.fromBank({
    required String bankName,
    required String accountNumber,
    required String ownerName,
  }) =>
      PaymentAccount(
        accountNumber: accountNumber,
        name: ownerName,
        provider: bankName,
        isService: false,
      );

  // Helper để tạo từ BankAccount2 (Dịch vụ)
  factory PaymentAccount.fromService({
    required String serviceName,
    required String provider,
    required String detail,
    required String accountNumber,
  }) =>
      PaymentAccount(
        accountNumber: accountNumber,
        name: serviceName,
        provider: provider,
        detail: detail,
        isService: true,
      );
}
