import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';

class PackageModel {
  final String name;
  final int price;
  final String description;

  PackageModel({required this.name, required this.price, required this.description});
}

class GenericPackageScreen extends StatefulWidget {
  final String title;
  final List<String> providers;
  final List<PackageModel> packages;

  const GenericPackageScreen({
    super.key,
    required this.title,
    required this.providers,
    required this.packages,
  });

  @override
  State<GenericPackageScreen> createState() => _GenericPackageScreenState();
}

class _GenericPackageScreenState extends State<GenericPackageScreen> {
  String? _selectedProvider;
  PackageModel? _selectedPackage;

  @override
  void initState() {
    super.initState();
    if (widget.providers.isNotEmpty) _selectedProvider = widget.providers[0];
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
                  const Text("Chọn nhà mạng", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.providers.map((p) {
                      final isSelected = _selectedProvider == p;
                      return ChoiceChip(
                        label: Text(p),
                        selected: isSelected,
                        onSelected: (val) => setState(() => _selectedProvider = p),
                        selectedColor: Colors.purple,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text("Chọn gói cước", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.packages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final pkg = widget.packages[index];
                      final isSelected = _selectedPackage == pkg;
                      return InkWell(
                        onTap: () => setState(() => _selectedPackage = pkg),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: isSelected ? Colors.purple : Colors.grey.shade300, width: 2),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected ? Colors.purple.withOpacity(0.05) : Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(pkg.description, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
                              ),
                              Text("${pkg.price ~/ 1000}K", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: (_selectedProvider != null && _selectedPackage != null)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransferMoneyFormScreen(
                            account: PaymentAccount.fromService(
                              serviceName: widget.title,
                              provider: _selectedProvider!,
                              detail: "Gói: ${_selectedPackage!.name}",
                              accountNumber: "PK/${_selectedPackage!.name}",
                            ),
                            presetAmount: _selectedPackage!.price,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("ĐĂNG KÝ NGAY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
