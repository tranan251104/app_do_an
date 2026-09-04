import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _selectedGender;
  DateTime? _selectedDate;
  final _nameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _addressController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    AppLogger.repo('PROFILE_UI', 'Loading profile data');
    try {
      final data = await AppServices.user.me();
      if (!mounted) return;
      setState(() {
        _nameController.text = data['fullName']?.toString() ?? '';
        final email = data['email']?.toString() ?? '';
        final phone = data['phone']?.toString() ?? '';
        _identifierController.text = email.isNotEmpty ? email : phone;
        _addressController.text = data['address']?.toString() ?? '';
        final gender = data['gender']?.toString() ?? '';
        _selectedGender = gender.isEmpty ? null : gender;
        _selectedDate = DateTime.tryParse(data['dateOfBirth']?.toString() ?? '');
      });
    } on ApiException catch (e) {
      _show(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    AppLogger.action('PROFILE save button pressed');
    setState(() => _loading = true);
    try {
      await AppServices.user.update(
        fullName: _nameController.text.trim(),
        dateOfBirth: _selectedDate,
        gender: _selectedGender,
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );
      if (!mounted) return;
      context.go('/goal');
    } on ApiException catch (e) {
      _show(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/DNA_BLUE_2103.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Cập nhật hồ sơ cá nhân'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Giúp chúng tôi xác thực tài khoản của bạn'.tr(),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _field(_nameController, 'Họ và tên'.tr(), Icons.person_outline),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _identifierController,
                            enabled: false,
                            decoration: _inputDeco('Email / Số điện thoại', Icons.alternate_email),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate ?? DateTime(2000),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) setState(() => _selectedDate = picked);
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                decoration: _inputDeco(
                                  _selectedDate == null
                                      ? 'Ngày sinh'.tr()
                                      : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                  Icons.calendar_today,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            decoration: _inputDeco('Giới tính'.tr(), Icons.wc),
                            value: _selectedGender,
                            items: const ['Nam', 'Nữ', 'Khác']
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (value) => setState(() => _selectedGender = value),
                          ),
                          const SizedBox(height: 10),
                          _field(_addressController, 'Địa chỉ'.tr(), Icons.location_on_outlined),
                          const SizedBox(height: 10),
                          const ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.credit_card),
                            title: Text('CMND/CCCD'),
                            subtitle: Text('Tạm chưa lưu cho tới khi backend hỗ trợ mã hóa CCCD.'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: ElevatedButton(
          onPressed: _loading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('TIẾP TỤC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String hint, IconData icon) {
    return TextField(controller: controller, decoration: _inputDeco(hint, icon));
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );
}
