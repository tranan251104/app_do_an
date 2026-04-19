import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrainTicketListScreen extends StatelessWidget {
  final int walletBalance;
  final String trainCode;
  final String routeName;

  TrainTicketListScreen({
    super.key,
    required this.walletBalance,
    required this.trainCode,
    required this.routeName,
  });

  final formatter = NumberFormat("#,###", "vi_VN");

  /// Map thời gian hành trình theo tuyến
  final Map<String, Duration> routeDurations = {
  "Hà Nội - Sài Gòn": const Duration(hours: 30),
  "Hà Nội - Vinh": const Duration(hours: 6),
  "Hà Nội - Hải Phòng": const Duration(hours: 2),
  "Hà Nội - Đà Nẵng": const Duration(hours: 16),
  "Hà Nội - Lào Cai": const Duration(hours: 8),
};

String normalizeRoute(String route) {
  return route.replaceAll("→", "-").trim();
}

Duration getDuration(String route) {
  final normalized = normalizeRoute(route);
  return routeDurations[normalized] ?? const Duration(hours: 5);
}

  /// Tạo 10 vé cho mỗi chuyến tàu
  List<Map<String, dynamic>> generateTickets(String train, String route) {
    final List<Map<String, dynamic>> tickets = [];
    final duration = getDuration(route);

    for (int i = 0; i < 10; i++) {
      // Khởi hành từ 6h sáng, cách nhau 2 tiếng
      DateTime start = DateTime(2025, 1, 1, 6 + i * 2);
      DateTime end = start.add(duration);

      // Tính tổng thời gian hành trình
      final journeyHours = duration.inHours;
      final days = journeyHours ~/ 24;
      final hours = journeyHours % 24;
      final journeyText = days > 0
          ? "$journeyHours giờ (~$days ngày $hours giờ)"
          : "$journeyHours giờ";

      tickets.add({
        "id": "$train-V${i + 1}",
        "start": start,
        "end": end,
        "journeyText": journeyText,
        "class": i % 2 == 0 ? "Ghế ngồi" : "Giường nằm",
        "price": i % 2 == 0 ? 100000 + i * 5000 : 300000 + i * 10000,
      });
    }
    return tickets;
  }

  void _bookTicket(BuildContext context, Map<String, dynamic> ticket) {
    if (ticket["price"] > walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Số dư ví không đủ!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "✅ Đặt vé ${ticket["id"]} thành công! Trừ ${formatter.format(ticket["price"])} VND"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tickets = generateTickets(trainCode, routeName);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết vé - $trainCode"),
        backgroundColor: Colors.purple,
      ),
      body: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          final startTime = dateFormat.format(ticket["start"]);
          final endTime = dateFormat.format(ticket["end"]);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(routeName),
              subtitle: Text(
                "⏰ $startTime → $endTime\n"
                "⏳ Thời gian: ${ticket["journeyText"]}\n"
                "🛏️ ${ticket["class"]} - 💰 ${formatter.format(ticket["price"])} VND",
              ),
              isThreeLine: true,
              trailing: ElevatedButton(
                onPressed: () => _bookTicket(context, ticket),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Đặt vé"),
              ),
            ),
          );
        },
      ),
    );
  }
}
