import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/navigator/navigator_screen/link_phone_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _isEditing = false;
  bool _loading = true;
  bool _phoneVerified = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    AppLogger.repo('PROFILE_UI', 'Load personal info');
    try {
      final data = await AppServices.user.me();
      final date = DateTime.tryParse(data['dateOfBirth']?.toString() ?? '');
      if (!mounted) return;
      setState(() {
        _nameController.text = data['fullName']?.toString() ?? '';
        _emailController.text = data['email']?.toString() ?? '';
        _phoneController.text = data['phone']?.toString() ?? '';
        _phoneVerified = data['phoneVerified'] == true;
        _dobController.text = date == null
            ? ''
            : DateFormat('dd/MM/yyyy').format(date);
        _genderController.text = data['gender']?.toString() ?? '';
        _addressController.text = data['address']?.toString() ?? '';
      });
    } on ApiException catch (e) {
      _show(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openLinkPhone() async {
    final linkedPhone = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => LinkPhoneScreen(initialPhone: _phoneController.text),
      ),
    );
    if (linkedPhone == null || !mounted) return;
    _show('Đã liên kết số điện thoại $linkedPhone');
    setState(() => _loading = true);
    await _loadProfile();
  }

  Future<void> _saveProfile() async {
    AppLogger.action('PERSONAL INFO save pressed');
    DateTime? dob;
    final rawDob = _dobController.text.trim();
    if (rawDob.isNotEmpty) {
      try {
        dob = DateFormat('dd/MM/yyyy').parseStrict(rawDob);
      } catch (_) {
        _show('Ngày sinh phải có dạng dd/MM/yyyy');
        return;
      }
    }

    try {
      await AppServices.user.update(
        fullName: _nameController.text.trim(),
        dateOfBirth: dob,
        gender: _genderController.text.trim().isEmpty
            ? null
            : _genderController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _isEditing = false);
      _show('Thông tin đã được lưu');
    } on ApiException catch (e) {
      _show(e.message);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _loading
                ? null
                : (_isEditing
                      ? _saveProfile
                      : () => setState(() => _isEditing = true)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                _field('Họ và tên', _nameController, editable: true),
                _field('Email', _emailController, editable: false),
                _phoneField(),
                _field(
                  'Ngày sinh (dd/MM/yyyy)',
                  _dobController,
                  editable: true,
                ),
                _field('Giới tính', _genderController, editable: true),
                _field('Địa chỉ', _addressController, editable: true),
                const ListTile(
                  title: Text('CMND/CCCD'),
                  subtitle: Text(
                    'Chưa đồng bộ: backend cần bổ sung API lưu CCCD mã hóa trước khi bật trường này.',
                  ),
                ),
              ],
            ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    required bool editable,
  }) {
    final canEdit = _isEditing && editable;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: canEdit
          ? TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ListTile(
              title: Text(label),
              subtitle: Text(
                controller.text.isEmpty ? 'Chưa cập nhật' : controller.text,
              ),
            ),
    );
  }

  Widget _phoneField() {
    final hasPhone = _phoneController.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: const Text('Số điện thoại'),
        subtitle: Text(hasPhone ? _phoneController.text : 'Chưa liên kết'),
        trailing: _phoneVerified
            ? const Chip(
                avatar: Icon(Icons.verified, size: 18, color: Colors.green),
                label: Text('Đã xác minh'),
              )
            : TextButton(
                onPressed: _loading ? null : _openLinkPhone,
                child: Text(hasPhone ? 'Xác minh' : 'Liên kết'),
              ),
      ),
    );
  }
}
