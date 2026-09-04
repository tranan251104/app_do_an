import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

Future<void> showTransactionDetailSheet(
  BuildContext context, {
  required String transactionId,
  Map<String, dynamic>? initialData,
}) {
  AppLogger.action('TRANSACTION detail sheet opened', {
    'id': AppLogger.mask(transactionId),
  });
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TransactionDetailSheet(
      transactionId: transactionId,
      initialData: initialData,
    ),
  );
}

class _TransactionDetailSheet extends StatefulWidget {
  final String transactionId;
  final Map<String, dynamic>? initialData;

  const _TransactionDetailSheet({
    required this.transactionId,
    this.initialData,
  });

  @override
  State<_TransactionDetailSheet> createState() => _TransactionDetailSheetState();
}

class _TransactionDetailSheetState extends State<_TransactionDetailSheet> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData;
    _load();
  }

  Future<void> _load() async {
    try {
      final detail = await AppServices.transaction.get(widget.transactionId);
      if (!mounted) return;
      setState(() {
        _data = detail;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _money(num value) => '${NumberFormat('#,###', 'vi_VN').format(value)} ₫';

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'Thành công';
      case 'PENDING':
      case 'OTP_REQUIRED':
        return 'Đang xử lý';
      case 'FAILED':
        return 'Thất bại';
      case 'CANCELLED':
      case 'CANCELED':
        return 'Đã hủy';
      default:
        return status.isEmpty ? 'Không xác định' : status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING':
      case 'OTP_REQUIRED':
        return Colors.orange;
      case 'FAILED':
      case 'CANCELLED':
      case 'CANCELED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _typeLabel(String type, String direction) {
    if (type == 'INTERNAL_TRANSFER') {
      return direction == 'IN' ? 'Nhận tiền AnPay' : 'Chuyển tiền AnPay';
    }
    if (type == 'EXTERNAL_BANK_TRANSFER') return 'Chuyển tiền ngân hàng';
    if (type == 'TOP_UP') return 'Nạp tiền';
    return 'Giao dịch AnPay';
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.84,
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: data == null
              ? _buildLoadingOrError()
              : _buildContent(data),
        ),
      ),
    );
  }

  Widget _buildLoadingOrError() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 52, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_error ?? 'Không tải được chi tiết giao dịch'),
          const SizedBox(height: 16),
          FilledButton(onPressed: _load, child: const Text('Thử lại')),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final amount = (data['amount'] as num?)?.toInt() ?? 0;
    final fee = (data['fee'] as num?)?.toInt() ?? 0;
    final direction = data['direction']?.toString().toUpperCase() ?? '';
    final incoming = direction == 'IN' || direction == 'CREDIT';
    final status = data['status']?.toString() ?? '';
    final type = data['type']?.toString() ?? '';
    final reference = data['reference']?.toString() ?? '';
    final counterpartyName = data['counterpartyName']?.toString();
    final counterpartyAccount = data['counterpartyAccount']?.toString();
    final bankName = data['bankName']?.toString();
    final description = data['description']?.toString();
    final providerReference = data['providerReference']?.toString();
    final simulated = data['simulated'] == true;
    final createdAt = DateTime.tryParse(data['createdAt']?.toString() ?? '')?.toLocal();
    final completedAt = DateTime.tryParse(data['completedAt']?.toString() ?? '')?.toLocal();
    final effectiveTime = completedAt ?? createdAt;

    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: _statusColor(status).withOpacity(0.12),
                    child: Icon(
                      status.toUpperCase() == 'COMPLETED'
                          ? Icons.check_circle
                          : status.toUpperCase() == 'FAILED'
                              ? Icons.cancel
                              : Icons.schedule,
                      color: _statusColor(status),
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '${incoming ? '+' : '-'}${_money(amount)}',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: incoming ? Colors.green.shade700 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _typeLabel(type, direction),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                if (_loading) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(minHeight: 2),
                ],
                const SizedBox(height: 22),
                _section(
                  children: [
                    if (counterpartyName != null && counterpartyName.isNotEmpty)
                      _row(
                        incoming ? 'Người gửi' : 'Người nhận',
                        counterpartyName,
                      ),
                    if (bankName != null && bankName.isNotEmpty)
                      _row('Ngân hàng', bankName),
                    if (counterpartyAccount != null && counterpartyAccount.isNotEmpty)
                      _row(
                        type == 'EXTERNAL_BANK_TRANSFER'
                            ? 'Số tài khoản'
                            : 'Số tài khoản AnPay',
                        counterpartyAccount,
                      ),
                    if (description != null && description.trim().isNotEmpty)
                      _row('Nội dung', description.trim()),
                    _row('Phí', _money(fee)),
                  ],
                ),
                const SizedBox(height: 12),
                _section(
                  children: [
                    if (effectiveTime != null)
                      _row(
                        'Thời gian',
                        DateFormat('HH:mm:ss · dd/MM/yyyy').format(effectiveTime),
                      ),
                    if (reference.isNotEmpty)
                      _row(
                        'Mã giao dịch',
                        reference,
                        copyValue: reference,
                      ),
                    if (providerReference != null && providerReference.isNotEmpty)
                      _row(
                        'Mã đối soát',
                        providerReference,
                        copyValue: providerReference,
                      ),
                  ],
                ),
                if (simulated) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.science_outlined, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Giao dịch này được thực hiện trong môi trường mô phỏng AnPay.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 18),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _section({required List<Widget> children}) {
    final visible = children.where((widget) => widget is! SizedBox).toList();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: visible),
    );
  }

  Widget _row(String label, String value, {String? copyValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          if (copyValue != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: copyValue));
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã sao chép')),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.copy, size: 17, color: Colors.purple),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
