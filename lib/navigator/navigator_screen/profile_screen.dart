import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _selectedGender;
  DateTime? _selectedDate;
  String _loginMethod = "email"; // 🔹 Để phân biệt Email/Phone

  final _nameController = TextEditingController();
  final _identifierController = TextEditingController(); // 🔹 Dùng chung cho Email hoặc Phone
  final _addressController = TextEditingController();
  final _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final method = prefs.getString("login_method") ?? "email";

    setState(() {
      _loginMethod = method;
      _nameController.text = prefs.getString("name") ?? "";
      // Lấy Email hoặc Phone tùy theo mode đăng nhập
      _identifierController.text = method == "email" 
          ? (prefs.getString("user_email") ?? "") 
          : (prefs.getString("user_phone") ?? "");
    });

    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data["fullName"] ?? _nameController.text;
          _addressController.text = data["address"] ?? "";
          _idController.text = data["idCard"] ?? "";
          _selectedGender = data["gender"];
          
          final dob = data["dob"] ?? "";
          if (dob.isNotEmpty) {
            final parts = dob.split("/");
            if (parts.length == 3) {
              _selectedDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            }
          }
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final dobStr = _selectedDate != null ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}" : "";

    final Map<String, dynamic> updateData = {
      "fullName": _nameController.text.trim(),
      "dob": dobStr,
      "gender": _selectedGender ?? "",
      "address": _addressController.text.trim(),
      "idCard": _idController.text.trim(),
      "updatedAt": FieldValue.serverTimestamp(),
    };

    // Thêm email hoặc phone vào data tùy theo loại tài khoản
    if (_loginMethod == "email") {
      updateData["email"] = _identifierController.text.trim();
    } else {
      updateData["phone"] = _identifierController.text.trim();
    }

    if (user != null) {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set(updateData, SetOptions(merge: true));
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", _nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildBanner(),
            _buildIntro(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildReadonlyField(_nameController, "Họ và tên".tr(), Icons.person_outline),
                    const SizedBox(height: 10),
                    // 🔹 Tự động đổi Icon dựa trên Email/Phone
                    _buildReadonlyField(
                      _identifierController, 
                      _loginMethod == "email" ? "Email".tr() : "Số điện thoại".tr(), 
                      _loginMethod == "email" ? Icons.email_outlined : Icons.phone
                    ),
                    const SizedBox(height: 10),
                    _buildDatePicker(),
                    const SizedBox(height: 10),
                    _buildGenderDropdown(),
                    const SizedBox(height: 10),
                    _buildEditableField(_addressController, "Địa chỉ".tr(), Icons.location_on_outlined),
                    const SizedBox(height: 10),
                    _buildEditableField(_idController, "CMND/CCCD".tr(), Icons.credit_card),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildNextButton(),
    );
  }

  Widget _buildBanner() => SizedBox(
    height: MediaQuery.of(context).size.height * 0.25,
    width: double.infinity,
    child: Image.asset("assets/images/DNA_BLUE_2103.png", fit: BoxFit.cover),
  );

  Widget _buildIntro() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        Text("Cập nhật hồ sơ cá nhân".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 4),
        Text("Giúp chúng tôi xác thực tài khoản của bạn".tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    ),
  );

  Widget _buildReadonlyField(TextEditingController ctrl, String hint, IconData icon) => TextField(
    controller: ctrl, enabled: false, decoration: _inputDeco(hint, icon),
  );

  Widget _buildEditableField(TextEditingController ctrl, String hint, IconData icon) => TextField(
    controller: ctrl, decoration: _inputDeco(hint, icon),
  );

  Widget _buildDatePicker() => GestureDetector(
    onTap: () async {
      final picked = await showDatePicker(context: context, initialDate: DateTime(2000), firstDate: DateTime(1900), lastDate: DateTime.now());
      if (picked != null) setState(() => _selectedDate = picked);
    },
    child: AbsorbPointer(
      child: TextField(
        decoration: _inputDeco(_selectedDate == null ? "Ngày sinh".tr() : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}", Icons.calendar_today),
      ),
    ),
  );

  Widget _buildGenderDropdown() => DropdownButtonFormField<String>(
    decoration: _inputDeco("Giới tính".tr(), Icons.wc),
    value: _selectedGender,
    items: ['Nam', 'Nữ', 'Khác'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
    onChanged: (v) => setState(() => _selectedGender = v),
  );

  Widget _buildNextButton() => Padding(
    padding: const EdgeInsets.all(24),
    child: ElevatedButton(
      onPressed: () async {
        await _saveProfile();
        if (mounted) context.go('/goal');
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      child: const Text("TIẾP TỤC", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    prefixIcon: Icon(icon), hintText: hint, filled: true, fillColor: Colors.grey[100],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
  );
}
