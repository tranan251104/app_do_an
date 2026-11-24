import 'package:app_do_an/core/app_services.dart';
import 'package:app_do_an/core/network/api_exception.dart';
import 'package:app_do_an/features/smart_otp/presentation/smart_otp_flow.dart';
import 'package:app_do_an/navigator/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Required step between *both* registration modes/login and the home page.
/// Uses live backend state rather than a local "onboarded" preference.
class SmartOtpOnboardingScreen extends StatefulWidget {
  const SmartOtpOnboardingScreen({super.key, required this.next});
  final String next;

  @override
  State<SmartOtpOnboardingScreen> createState() => _SmartOtpOnboardingScreenState();
}

class _SmartOtpOnboardingScreenState extends State<SmartOtpOnboardingScreen> {
  bool _loading = true;
  bool _setupRequired = false;
  bool _missingLocalKey = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  String get _nextRoute => switch (widget.next) {
    'profile' => '/profile',
    'wallet' => '/wallet-number?finish=main',
    _ => '/main?fromLogin=true',
  };

  Future<void> _check() async {
    if (!mounted) return;
    setState(() { _loading = true; _setupRequired = false; _missingLocalKey = false; _error = null; });
    try {
      final status = await AppServices.smartOtp.status();
      if (!mounted) return;
      final deviceId = status['deviceId']?.toString() ?? '';
      if (status['active'] == true) {
        if (deviceId.isNotEmpty &&
            (await AppServices.smartOtpKeyStore.hasLocalDevice(deviceId) ||
             await AppServices.smartOtpKeyStore.recoverConfirmedDevice(deviceId))) {
          if (mounted) context.go(_nextRoute);
          return;
        }
        setState(() { _missingLocalKey = true; _loading = false; });
        return;
      }

      // Phone-only users must register FCM before backend sends the
      // independent activation OTP. The initial phone-registration OTP and
      // this activation OTP are separate challenges.
      final me = await AppServices.user.me();
      final hasEmail = (me['email']?.toString().trim() ?? '').isNotEmpty;
      if (!hasEmail) {
        final registered = await NotificationService.registerCurrentDevice(
          source: 'smart_otp_onboarding',
        );
        if (!registered) {
          throw StateError('Chưa đăng ký được thiết bị FCM để nhận OTP kích hoạt.');
        }
      }
      if (mounted) setState(() { _setupRequired = true; _loading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Không thể kiểm tra Smart OTP: $e'; _loading = false; });
    }
  }

  Future<void> _logout() async {
    await NotificationService.unregisterCurrentDevice();
    await AppServices.auth.logout();
    if (mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    // Both hardware Back and the app-bar back arrow must not skip activation.
    return PopScope(
      canPop: false,
      child: _setupRequired
          ? SmartOtpSetupScreen(mandatory: true, onActivated: _check)
          : Scaffold(
              appBar: AppBar(automaticallyImplyLeading: false, title: const Text('AnPay Smart OTP')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user_outlined, size: 64, color: Colors.indigo),
                            const SizedBox(height: 16),
                            Text(
                              _missingLocalKey
                                  ? 'Tài khoản đã có Smart OTP trên thiết bị khác hoặc khóa cục bộ đã mất.'
                                  : _error ?? 'Bạn cần kích hoạt Smart OTP để tiếp tục.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            if (_missingLocalKey)
                              FilledButton(
                                onPressed: () async {
                                  await Navigator.of(context).push<void>(
                                    MaterialPageRoute(builder: (_) => const SmartOtpManagementScreen()),
                                  );
                                  if (mounted) await _check();
                                },
                                child: const Text('Quản lý thiết bị Smart OTP'),
                              ),
                            OutlinedButton(onPressed: _check, child: const Text('Thử lại')),
                            TextButton(onPressed: _logout, child: const Text('Đăng xuất')),
                          ],
                        ),
                ),
              ),
            ),
    );
  }
}
