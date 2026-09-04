import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/model/payment_account.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';
import 'package:intl/intl.dart';

class PackageModel {
  final String code;
  final String name;
  final int price;
  final String description;

  PackageModel({
    String? code,
    required this.name,
    required this.price,
    required this.description,
  }) : code = code ?? name;
}

class GenericPackageScreen extends StatefulWidget {
  final String title;
  final List<String> providers;
  final List<PackageModel> packages;
  final Map<String, List<PackageModel>>? packagesByProvider;
  final String providerLabel;
  final String packageLabel;
  final String searchHint;
  final String actionLabel;
  final String itemUnit;
  final String selectionLabel;

  const GenericPackageScreen({
    super.key,
    required this.title,
    required this.providers,
    this.packages = const [],
    this.packagesByProvider,
    this.providerLabel = "Chọn nhà cung cấp",
    this.packageLabel = "Chọn gói hoặc dịch vụ",
    this.searchHint = "Tìm theo tên hoặc nội dung",
    this.actionLabel = "THANH TOÁN NGAY",
    this.itemUnit = "gói",
    this.selectionLabel = "Gói",
  });

  @override
  State<GenericPackageScreen> createState() => _GenericPackageScreenState();
}

class _GenericPackageScreenState extends State<GenericPackageScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedProvider;
  PackageModel? _selectedPackage;
  String _searchQuery = '';

  List<PackageModel> get _providerPackages {
    final packagesByProvider = widget.packagesByProvider;
    if (packagesByProvider != null && _selectedProvider != null) {
      return packagesByProvider[_selectedProvider] ?? const [];
    }
    return widget.packages;
  }

  List<PackageModel> get _visiblePackages {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _providerPackages;

    return _providerPackages
        .where((package) {
          return package.name.toLowerCase().contains(query) ||
              package.description.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    if (widget.providers.isNotEmpty) _selectedProvider = widget.providers[0];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  Text(
                    widget.providerLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: widget.providers.map((p) {
                      final isSelected = _selectedProvider == p;
                      return ChoiceChip(
                        label: Text(p),
                        selected: isSelected,
                        onSelected: (val) {
                          if (!val) return;
                          AppLogger.action('SERVICE provider selected', {'screen': widget.title, 'provider': p});
                          _searchController.clear();
                          setState(() {
                            _selectedProvider = p;
                            _selectedPackage = null;
                            _searchQuery = '';
                          });
                        },
                        selectedColor: Colors.purple,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    key: const Key('package-search-field'),
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              tooltip: "Xóa tìm kiếm",
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              icon: const Icon(Icons.close),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.packageLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${_visiblePackages.length} ${widget.itemUnit}",
                        key: const Key('package-count'),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_visiblePackages.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text("Không tìm thấy gói phù hợp")),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _visiblePackages.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final pkg = _visiblePackages[index];
                        final isSelected = _selectedPackage == pkg;
                        return InkWell(
                          onTap: () {
                            AppLogger.action('SERVICE package selected', {'screen': widget.title, 'package': pkg.name, 'price': pkg.price});
                            setState(() => _selectedPackage = pkg);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Colors.purple
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? Colors.purple.withValues(alpha: 0.05)
                                  : Colors.white,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pkg.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        pkg.description,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "${NumberFormat.decimalPattern('vi_VN').format(pkg.price)}đ",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
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
                      AppLogger.action('SERVICE checkout pressed', {'screen': widget.title, 'provider': _selectedProvider, 'package': _selectedPackage?.name, 'price': _selectedPackage?.price});
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransferMoneyFormScreen(
                            account: PaymentAccount.fromService(
                              serviceName: widget.title,
                              provider: _selectedProvider!,
                              detail:
                                  "${widget.selectionLabel}: ${_selectedPackage!.name}",
                              accountNumber: "PK/${_selectedPackage!.code}",
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.actionLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
