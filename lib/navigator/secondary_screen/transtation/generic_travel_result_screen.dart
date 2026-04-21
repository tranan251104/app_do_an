import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/service/app_data.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';
import 'package:intl/intl.dart';

class GenericTravelResultScreen extends StatelessWidget {
  final String title;
  final String type;
  final String from;
  final String to;
  final String date;

  const GenericTravelResultScreen({
    super.key,
    required this.title,
    required this.type,
    required this.from,
    required this.to,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 Cập nhật truyền đủ 3 tham số để lọc chuyến đi theo route
    final List<TripModel> trips = AppData.getMockTrips(type, from, to);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$from - $to", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(date, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.purple.shade50,
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.purple),
                const SizedBox(width: 8),
                Text("Tìm thấy ${trips.length} chuyến đi phù hợp", style: const TextStyle(fontSize: 13, color: Colors.purple)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final trip = trips[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransferMoneyFormScreen(
                          account2: BankAccount2(
                            serviceName: title,
                            provider: trip.brand,
                            detail: "$from -> $to | ${trip.time} | ${trip.type}",
                            accountNumber: "TRIP/${type.toUpperCase()}/${index}",
                          ),
                          presetAmount: trip.price,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(trip.brand, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple)),
                            Text("${NumberFormat.decimalPattern().format(trip.price)}đ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(trip.time, style: const TextStyle(color: Colors.black87)),
                            const SizedBox(width: 16),
                            const Icon(Icons.airline_seat_recline_extra, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(trip.type, style: const TextStyle(color: Colors.black87)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
