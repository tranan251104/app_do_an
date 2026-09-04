class PaymentAccount {
  final String accountNumber;
  final String name;
  final String provider;
  final String? detail;
  final bool isService;
  final String? bankBin;
  final String? bankCode;
  final String? logoUrl;

  PaymentAccount({
    required this.accountNumber,
    required this.name,
    required this.provider,
    this.detail,
    this.isService = false,
    this.bankBin,
    this.bankCode,
    this.logoUrl,
  });

  Map<String, dynamic> toJson() => {
        'accountNumber': accountNumber,
        'name': name,
        'provider': provider,
        'detail': detail,
        'isService': isService,
        'bankBin': bankBin,
        'bankCode': bankCode,
        'logoUrl': logoUrl,
      };

  factory PaymentAccount.fromJson(Map<String, dynamic> json) {
    return PaymentAccount(
      accountNumber: json['accountNumber']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      detail: json['detail']?.toString(),
      isService: json['isService'] == true,
      bankBin: json['bankBin']?.toString(),
      bankCode: json['bankCode']?.toString(),
      logoUrl: json['logoUrl']?.toString(),
    );
  }

  factory PaymentAccount.fromBank({
    required String bankName,
    required String accountNumber,
    required String ownerName,
    String? bankBin,
    String? bankCode,
    String? logoUrl,
  }) =>
      PaymentAccount(
        accountNumber: accountNumber,
        name: ownerName,
        provider: bankName,
        isService: false,
        bankBin: bankBin,
        bankCode: bankCode,
        logoUrl: logoUrl,
      );

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
