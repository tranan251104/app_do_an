import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget buildInput({
  required Icon icon,
  required String hint,
  required TextEditingController controller,
  bool obscure = false,
  TextInputType? keyboardType,                 // 🔹 thêm vào
  List<TextInputFormatter>? inputFormatters,  // 🔹 thêm vào (nếu muốn giới hạn số, ký tự,…)
}) {
  return _InputField(
    icon: icon,
    hint: hint,
    controller: controller,
    obscure: obscure,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
  );
}

// Đặc tính chung của các ô nhập thông tin
class _InputField extends StatefulWidget {
  final Icon icon;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _InputField({
    required this.icon,
    required this.hint,
    required this.controller,
    required this.obscure,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,              // 🔹 thêm vào
        inputFormatters: widget.inputFormatters,        // 🔹 thêm vào
        decoration: InputDecoration(
          prefixIcon: widget.icon,
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          suffixIcon: widget.obscure
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

