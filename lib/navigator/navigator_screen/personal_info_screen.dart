import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool _isEditing = false;

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();
  final _idCardController = TextEditingController();

  String? _loginMethod; // 👈 để phân biệt login email / phone

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
  final prefs = await SharedPreferences.getInstance();
  _loginMethod = prefs.getString("login_method");

  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data["fullName"] ?? "";
        _emailController.text = data["email"] ?? "";
        _phoneController.text = data["phone"] ?? "";
        _dobController.text = data["dob"] ?? "";
        _genderController.text = data["gender"] ?? "";
        _addressController.text = data["address"] ?? "";
        _idCardController.text = data["idCard"] ?? "";
      });
      return; // 🔹 Ưu tiên Firestore
    }
  }

  // 🔹 fallback SharedPreferences
  setState(() {
    _nameController.text = prefs.getString("name") ?? "";
    if (_loginMethod == "email") {
      _emailController.text = prefs.getString("user_email") ?? "";
      _phoneController.text = "";
    } else if (_loginMethod == "phone") {
      _phoneController.text = prefs.getString("user_phone") ?? "";
      _emailController.text = "";
    }
    _dobController.text = prefs.getString("dob") ?? "";
    _genderController.text = prefs.getString("gender") ?? "";
    _addressController.text = prefs.getString("address") ?? "";
    _idCardController.text = prefs.getString("idCard") ?? "";
  });
}



  /// 🔹 Lưu dữ liệu (trừ name + email/phone vì cố định

Future<void> _saveProfile() async {
  final prefs = await SharedPreferences.getInstance();

  if (_loginMethod == "phone") {
    await prefs.setString("user_phone", _phoneController.text.trim());
  }

  await prefs.setString("dob", _dobController.text.trim());
  await prefs.setString("gender", _genderController.text.trim());
  await prefs.setString("address", _addressController.text.trim());
  await prefs.setString("idCard", _idCardController.text.trim());

  // 🔹 Đồng bộ Firestore
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    await FirebaseFirestore.instance.collection("users").doc(uid).set({
      "fullName": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "phone": _phoneController.text.trim(),
      "dob": _dobController.text.trim(),
      "gender": _genderController.text.trim(),
      "address": _addressController.text.trim(),
      "idCard": _idCardController.text.trim(),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  setState(() {
    _isEditing = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("✅ Thông tin đã được lưu")),
  );
}

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),

          // Họ và tên (readonly)
          _buildFixedField("Họ và tên", _nameController.text),

          // Email hoặc Phone tuỳ login_method
          if (_loginMethod == "email")
            _buildFixedField("Email", _emailController.text),
          if (_loginMethod == "phone")
            _buildFixedField("Số điện thoại", _phoneController.text),

          // Các field khác có thể edit
          _buildField("Ngày sinh", _dobController),
          _buildField("Giới tính", _genderController),
          _buildField("Địa chỉ", _addressController),
          _buildField("CMND/CCCD", _idCardController),
        ],
      ),
    );
  }

  /// 🔹 Field có thể edit
  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _isEditing
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
                controller.text.isNotEmpty ? controller.text : "Chưa cập nhật",
                style: const TextStyle(color: Colors.black87),
              ),
            ),
    );
  }

  /// 🔹 Field cố định (không cho edit)
  Widget _buildFixedField(String label, String value) {
    return ListTile(
      title: Text(label),
      subtitle: Text(
        value.isNotEmpty ? value : "Chưa cập nhật",
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }
}
