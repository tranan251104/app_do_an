import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageButton extends StatefulWidget {
  const LanguageButton({super.key});

  @override
  State<LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<LanguageButton> {
  Locale? _currentLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.locale;
    if (_currentLocale != locale) {
      setState(() {
        _currentLocale = locale;
      });
    }
  }

  // an nut thay doi ngon ngu 
  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Image.asset("assets/images/england.jpg", height: 25, width: 25),
            title: const Text("English"),
            onTap: () async {
              await context.setLocale(const Locale('en'));
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('language', 'en');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Image.asset("assets/images/vietnamese.jpeg", height: 25, width: 25),
            title: const Text("Vietnamese"),
            onTap: () async {
              await context.setLocale(const Locale('vi'));
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('language', 'vi');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;
    final flagAsset = langCode == 'vi'
        ? 'assets/images/vietnamese.jpeg'
        : 'assets/images/england.jpg';

    return SizedBox(
      height: 40,
      width: 40,
      child: ElevatedButton(
        onPressed: () => _showLanguageSelector(context),
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.all(6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(flagAsset, height: 20, width: 20),
        ),
      ),
    );
  }
}
