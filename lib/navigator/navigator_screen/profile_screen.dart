import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileEmailScreen extends StatefulWidget {
  const ProfileEmailScreen({super.key});

  @override
  State<ProfileEmailScreen> createState() => _ProfileEmailScreenState();
}

class _ProfileEmailScreenState extends State<ProfileEmailScreen> {
  String? _selectedGender;
  DateTime? _selectedDate;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFixedData();
  }

  Future<void> _loadFixedData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data["fullName"] ?? "";
          _emailController.text = data["email"] ?? "";
          _addressController.text = data["address"] ?? "";
          _idController.text = data["idCard"] ?? "";

          final dob = data["dob"] ?? "";
          if (dob.isNotEmpty) {
            final parts = dob.split("/");
            if (parts.length == 3) {
              _selectedDate = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );
            }
          }
          _selectedGender = data["gender"] ?? "";
        });
        return;
      }
    }

    setState(() {
      _nameController.text = prefs.getString("name") ?? "";
      _emailController.text = prefs.getString("email") ?? "";
      _addressController.text = prefs.getString("address") ?? "";
      _idController.text = prefs.getString("idCard") ?? "";

      final dob = prefs.getString("dob") ?? "";
      if (dob.isNotEmpty) {
        final parts = dob.split("/");
        if (parts.length == 3) {
          _selectedDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
      _selectedGender = prefs.getString("gender") ?? "";
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("name", _nameController.text.trim());
    await prefs.setString(
        "dob",
        _selectedDate != null
            ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
            : "");
    await prefs.setString("gender", _selectedGender ?? "");
    await prefs.setString("address", _addressController.text.trim());
    await prefs.setString("idCard", _idController.text.trim());

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "fullName": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "dob": _selectedDate != null
            ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
            : "",
        "gender": _selectedGender ?? "",
        "address": _addressController.text.trim(),
        "idCard": _idController.text.trim(),
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildReadonlyField(_nameController, "Họ và tên".tr(), Icons.person_outline),
                      const SizedBox(height: 10),
                      _buildReadonlyField(_emailController, "Email".tr(), Icons.email_outlined),
                      const SizedBox(height: 10),
                      _buildDatePicker(context),
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
            ),
          ],
        ),
      ),

      // 👇 Nút Next luôn cố định đáy, không bị cuộn theo bàn phím
      bottomNavigationBar: _buildNextButton(),
    );
  }

  Widget _buildBanner() => Container(
        height: MediaQuery.of(context).size.height * 0.3,
        width: double.infinity,
        child: Image.asset("assets/images/DNA_BLUE_2103.png", fit: BoxFit.cover),
      );

  Widget _buildIntro() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Text("Cập nhật hồ sơ cá nhân".tr(),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, fontFamily: "Poppins")),
            const SizedBox(height: 3),
            Text("Giúp chúng tôi xác thực tài khoản của bạn".tr(),
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: "Poppins")),
            const SizedBox(height: 10),
          ],
        ),
      );

  Widget _buildReadonlyField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      enabled: false,
      decoration: _buildInputDecoration(hint, icon),
    );
  }

  Widget _buildEditableField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: _buildInputDecoration(hint, icon),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: AbsorbPointer(
        child: TextField(
          decoration: _buildInputDecoration(
            _selectedDate == null
                ? "Ngày sinh".tr()
                : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
            Icons.calendar_today,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _buildInputDecoration("Giới tính".tr(), Icons.wc),
      value: ['Nam', 'Nữ', 'Khác'].contains(_selectedGender) ? _selectedGender : null,
      hint: Text("Chọn giới tính"),
      items: ['Nam', 'Nữ', 'Khác']
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (val) => setState(() => _selectedGender = val),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await _saveProfile();
            /*Navigator.push(
              context,
              CupertinoPageRoute(builder: (_) => GoalScreen()),
            );*/
            context.go('/goal');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Next".tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_right_alt_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
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
}

