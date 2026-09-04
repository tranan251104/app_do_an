class BankOption {
  final String code;
  final String bin;
  final String name;
  final String logoUrl;
  final List<String> aliases;

  const BankOption({
    required this.code,
    required this.bin,
    required this.name,
    required this.logoUrl,
    this.aliases = const [],
  });

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return code.toLowerCase().contains(q) ||
        bin.contains(q) ||
        name.toLowerCase().contains(q) ||
        aliases.any((e) => e.toLowerCase().contains(q));
  }
}

const List<BankOption> bankCatalog = [
  BankOption(
    code: 'MB',
    bin: '970422',
    name: 'MB Bank',
    logoUrl: 'https://api.vietqr.io/img/MB.png',
    aliases: ['MBBank', 'Quan doi'],
  ),
  BankOption(
    code: 'VCB',
    bin: '970436',
    name: 'Vietcombank',
    logoUrl: 'https://api.vietqr.io/img/VCB.png',
    aliases: ['Ngoai thuong'],
  ),
  BankOption(
    code: 'TCB',
    bin: '970407',
    name: 'Techcombank',
    logoUrl: 'https://api.vietqr.io/img/TCB.png',
  ),
  BankOption(
    code: 'BIDV',
    bin: '970418',
    name: 'BIDV',
    logoUrl: 'https://api.vietqr.io/img/BIDV.png',
  ),
  BankOption(
    code: 'VBA',
    bin: '970405',
    name: 'Agribank',
    logoUrl: 'https://api.vietqr.io/img/VBA.png',
    aliases: ['Nong nghiep'],
  ),
  BankOption(
    code: 'VPB',
    bin: '970432',
    name: 'VPBank',
    logoUrl: 'https://api.vietqr.io/img/VPB.png',
  ),
  BankOption(
    code: 'ACB',
    bin: '970416',
    name: 'ACB',
    logoUrl: 'https://api.vietqr.io/img/ACB.png',
  ),
  BankOption(
    code: 'TPB',
    bin: '970423',
    name: 'TPBank',
    logoUrl: 'https://api.vietqr.io/img/TPB.png',
  ),
  BankOption(
    code: 'VIB',
    bin: '970441',
    name: 'VIB',
    logoUrl: 'https://api.vietqr.io/img/VIB.png',
  ),
  BankOption(
    code: 'STB',
    bin: '970403',
    name: 'Sacombank',
    logoUrl: 'https://api.vietqr.io/img/STB.png',
  ),
  BankOption(
    code: 'OCB',
    bin: '970448',
    name: 'OCB',
    logoUrl: 'https://api.vietqr.io/img/OCB.png',
  ),
  BankOption(
    code: 'MSB',
    bin: '970426',
    name: 'MSB',
    logoUrl: 'https://api.vietqr.io/img/MSB.png',
  ),
  BankOption(
    code: 'SHB',
    bin: '970443',
    name: 'SHB',
    logoUrl: 'https://api.vietqr.io/img/SHB.png',
  ),
  BankOption(
    code: 'HDB',
    bin: '970437',
    name: 'HDBank',
    logoUrl: 'https://api.vietqr.io/img/HDB.png',
  ),
  BankOption(
    code: 'SEAB',
    bin: '970440',
    name: 'SeABank',
    logoUrl: 'https://api.vietqr.io/img/SEAB.png',
  ),
  BankOption(
    code: 'NAB',
    bin: '970428',
    name: 'Nam A Bank',
    logoUrl: 'https://api.vietqr.io/img/NAB.png',
  ),
];

BankOption? bankByBin(String? bin) {
  if (bin == null || bin.trim().isEmpty) return null;
  for (final bank in bankCatalog) {
    if (bank.bin == bin.trim()) return bank;
  }
  return null;
}

BankOption? bankByName(String? name) {
  if (name == null || name.trim().isEmpty) return null;
  final target = name.trim().toLowerCase();
  for (final bank in bankCatalog) {
    if (bank.name.toLowerCase() == target ||
        bank.code.toLowerCase() == target ||
        bank.aliases.any((e) => e.toLowerCase() == target)) {
      return bank;
    }
  }
  return null;
}
