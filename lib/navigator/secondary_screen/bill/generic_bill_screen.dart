import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';

class GenericBillScreen extends StatefulWidget {
  final String title;
  final String inputLabel;
  final String hintText;
  final String serviceType; // 'electric', 'water', 'internet'...
  final List<String> providers;

  const GenericBillScreen({
    super.key,
    required this.title,
    required this.inputLabel,
    required this.hintText,
    required this.serviceType,
    required this.providers,
  });

  @override
  State<GenericBillScreen> createState() => _GenericBillScreenState();
}

class _GenericBillScreenState extends State<GenericBillScreen> {
  final TextEditingController _idController = TextEditingController();
  String? _selectedProvider;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    if (widget.providers.isNotEmpty) {
      _selectedProvider = widget.providers[0];
    }
    _idController.addListener(() {
      setState(() => _isValid = _idController.text.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Nhà cung cấp", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedProvider,
                        isExpanded: true,
                        items: widget.providers.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedProvider = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(widget.inputLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Mã khách hàng thường được in trên hóa đơn giấy hoặc tin nhắn thông báo tiền cước hàng tháng.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isValid ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransferMoneyFormScreen(
                      account: PaymentAccount.fromService(
                        serviceName: widget.title,
                        provider: _selectedProvider ?? "N/A",
                        detail: "Mã KH: ${_idController.text}",
                        accountNumber: _idController.text,
                      ),
                    ),
                  ),
                );
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("TIẾP TỤC", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
