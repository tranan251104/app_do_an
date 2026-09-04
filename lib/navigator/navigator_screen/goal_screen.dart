import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/navigator/service/notification_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _StateGoalScreen();
}

class _StateGoalScreen extends State<GoalScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;
  bool _assigningRandom = false;

  final List<Map<String, String>> pages = [
    {
      'image': 'assets/images/icon3.png',
      'title': 'Easy Account Setup'.tr(),
      'description': 'Open your bank account in minutes,'.tr(),
      'description2': 'no paperwork required,'.tr(),
      'description3': 'quick and secure verification.'.tr(),
    },
    {
      'image': 'assets/images/icon2.png',
      'title': 'Fast & Secure Transfers'.tr(),
      'description': 'Send and receive money instantly,'.tr(),
      'description2': 'with advanced protection to keep'.tr(),
      'description3': 'your transactions safe.'.tr(),
    },
    {
      'image': 'assets/images/icon3.png',
      'title': 'Smart & Convenient Payments'.tr(),
      'description': 'Pay bills, top up services,'.tr(),
      'description2': 'and manage your expenses'.tr(),
      'description3': 'all in one app.'.tr(),
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _primaryAction() async {
    AppLogger.action('ONBOARDING primary pressed', {'pageIndex': currentIndex});
    if (currentIndex < pages.length - 1) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRegistered', true);
    if (!mounted) return;
    context.go('/wallet-number?finish=login');
  }

  Future<void> _assignRandomAndFinish() async {
    AppLogger.action('ONBOARDING skip beautiful number pressed');
    setState(() => _assigningRandom = true);
    try {
      final wallet = await AppServices.wallet.assignRandomAccountNumber();
      final walletCode = wallet['walletCode']?.toString() ?? '';
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 52),
          title: const Text('Số tài khoản AnPay đã được tạo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Hệ thống đã cấp cho bạn:'),
              const SizedBox(height: 12),
              SelectableText(
                walletCode,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.deepPurple,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('ĐẾN ĐĂNG NHẬP'),
            ),
          ],
        ),
      );

      await NotificationService.unregisterCurrentDevice();
      await AppServices.auth.logout();
      if (!mounted) return;
      context.go('/welcome');
    } on ApiException catch (e) {
      _show(e.message);
    } finally {
      if (mounted) setState(() => _assigningRandom = false);
    }
  }

  void _show(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isLast = currentIndex == pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              'Khám phá AnPay'.tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ba bước nhanh trước khi hoàn tất tài khoản',
              style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => currentIndex = index),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade100, Colors.blue.shade300],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.asset(page['image']!, fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 80),
                            child: Divider(thickness: 1, color: Colors.white.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 6),
                          Text(page['description']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          const SizedBox(height: 3),
                          Text(page['description2']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          const SizedBox(height: 3),
                          Text(page['description3']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: index == currentIndex ? 22 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index == currentIndex ? Colors.blueAccent : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 8),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLast ? Colors.deepPurple : Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _assigningRandom ? null : _primaryAction,
                  child: Text(
                    isLast ? 'CHỌN SỐ TÀI KHOẢN' : 'TIẾP TỤC',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Poppins'),
                  ),
                ),
              ),
            ),
            if (isLast)
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 18),
                child: TextButton.icon(
                  onPressed: _assigningRandom ? null : _assignRandomAndFinish,
                  icon: _assigningRandom
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.casino_outlined),
                  label: const Text('Bỏ qua - nhận số ngẫu nhiên'),
                ),
              )
            else
              const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
