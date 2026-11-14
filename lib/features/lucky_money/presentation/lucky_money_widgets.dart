import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const envelopeTemplates = {
  'PROSPERITY': (
    'Tài lộc',
    Color(0xFFB52438),
    'Chúc bạn tài lộc đầy nhà, vạn sự như ý!',
  ),
  'PEACE': (
    'Bình an',
    Color(0xFF7350A2),
    'Chúc bạn luôn bình an, sức khỏe và hạnh phúc!',
  ),
  'JOY': (
    'Niềm vui',
    Color(0xFFB65C18),
    'Gửi bạn chút may mắn, chúc mỗi ngày đều rạng rỡ!',
  ),
};

String luckyAmount(int amount) =>
    '${NumberFormat.decimalPattern('vi').format(amount)} ₫';
String luckyDate(DateTime date) =>
    DateFormat('HH:mm dd/MM/yyyy').format(date.toLocal());

class EnvelopeCard extends StatelessWidget {
  final String template, greeting;
  final String? recipient;
  final int? amount;
  const EnvelopeCard({
    super.key,
    required this.template,
    required this.greeting,
    this.recipient,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final style = envelopeTemplates[template] ?? envelopeTemplates.values.first;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [style.$2, style.$2.withValues(alpha: .85)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.card_giftcard_rounded,
            size: 52,
            color: Color(0xFFFFD77A),
          ),
          const SizedBox(height: 12),
          Text(
            style.$1.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFFFD77A),
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (recipient != null) ...[
            const SizedBox(height: 12),
            Text(
              recipient!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            amount == null
                ? 'Một chút may mắn dành cho bạn'
                : luckyAmount(amount!),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: amount == null ? 18 : 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            greeting,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, height: 1.5),
          ),
        ],
      ),
    );
  }
}
