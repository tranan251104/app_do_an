//Thong tin hien thi o man hinh ket qua giao dich doi voi thanh toan cac dich vu

class BankAccount2 {
  final String serviceName;   // Tên dịch vụ, ví dụ: "Nhạc chờ", "Đăng ký 4G"
  final String provider;      // Nhà cung cấp, ví dụ: "Viettel iMuzik", "Vinaphone"
  final String detail;        // Chi tiết gói hoặc tên bài hát
  final String accountNumber; // Mã giao dịch nội bộ (log lại cho dễ)

  BankAccount2({
    required this.serviceName,
    required this.provider,
    required this.detail,
    required this.accountNumber,
  });

  Map<String, dynamic> toJson() => {
        "serviceName": serviceName,
        "provider": provider,
        "detail": detail,
        "accountNumber": accountNumber,
      };

  factory BankAccount2.fromJson(Map<String, dynamic> json) {
    return BankAccount2(
      serviceName: json["serviceName"],
      provider: json["provider"],
      detail: json["detail"],
      accountNumber: json["accountNumber"],
    );
  }
}
