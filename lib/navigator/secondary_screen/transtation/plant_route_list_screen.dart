import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';

class PlaneRouteListScreen extends StatefulWidget {
  final int walletBalance;
  const PlaneRouteListScreen({super.key, required this.walletBalance});

  @override
  State<PlaneRouteListScreen> createState() => _PlaneRouteListScreenState();
}

class _PlaneRouteListScreenState extends State<PlaneRouteListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final formatter = NumberFormat("#,###", "vi_VN");

  // 🔽 Bảng ánh xạ mã hãng -> tên hãng
  final Map<String, String> airlines = {
    "VN": "Vietnam Airlines",
    "VJ": "Vietjet Air",
    "QH": "Bamboo Airways",
    "VU": "Vietravel Airlines",
    "BL": "Pacific Airlines",
  };

  // 🔽 Danh sách chuyến bay nội địa
  final List<Map<String, dynamic>> domesticFlights = [
    {"flight": "VN220", "route": "Hà Nội (HAN) → TP.HCM (SGN)"},
    {"flight": "VN155", "route": "Hà Nội (HAN) → Đà Nẵng (DAD)"},
    {"flight": "VJ745", "route": "TP.HCM (SGN) → Phú Quốc (PQC)"},
    {"flight": "QH121", "route": "Hà Nội (HAN) → Nha Trang (CXR)"},
    {"flight": "VN789", "route": "TP.HCM (SGN) → Đà Nẵng (DAD)"},
    {"flight": "VJ456", "route": "Hà Nội (HAN) → Huế (HUI)"},
    {"flight": "VN301", "route": "Đà Nẵng (DAD) → Hà Nội (HAN)"},
    {"flight": "QH333", "route": "TP.HCM (SGN) → Đà Lạt (DLI)"},
    {"flight": "VJ678", "route": "Hà Nội (HAN) → Phú Quốc (PQC)"},
    {"flight": "VN555", "route": "TP.HCM (SGN) → Hải Phòng (HPH)"},
  ];

  // 🔽 Danh sách chuyến bay quốc tế
  final List<Map<String, dynamic>> internationalFlights = [
    {"flight": "VN301", "route": "Hà Nội (HAN) → Singapore (SIN)"},
    {"flight": "VJ915", "route": "TP.HCM (SGN) → Bangkok (BKK)"},
    {"flight": "VN417", "route": "Hà Nội (HAN) → Seoul (ICN)"},
    {"flight": "QH707", "route": "TP.HCM (SGN) → Kuala Lumpur (KUL)"},
    {"flight": "VN923", "route": "Hà Nội (HAN) → Tokyo (NRT)"},
    {"flight": "VJ865", "route": "TP.HCM (SGN) → Hong Kong (HKG)"},
    {"flight": "VN931", "route": "Hà Nội (HAN) → Paris (CDG)"},
    {"flight": "VN111", "route": "TP.HCM (SGN) → Sydney (SYD)"},
    {"flight": "VN223", "route": "Hà Nội (HAN) → Frankfurt (FRA)"},
    {"flight": "VN441", "route": "TP.HCM (SGN) → Los Angeles (LAX)"},
    {"flight": "VN575", "route": "Hà Nội (HAN) → Dubai (DXB)"},
  ];

  // 🔽 Thời lượng bay theo mã chuyến bay
  final Map<String, Duration> flightDurations = {
    "VN220": const Duration(hours: 2, minutes: 15),
    "VN155": const Duration(hours: 1, minutes: 30),
    "VJ745": const Duration(hours: 1),
    "QH121": const Duration(hours: 2),
    "VN789": const Duration(hours: 1, minutes: 30),
    "VJ456": const Duration(hours: 1, minutes: 15),
    "VN301": const Duration(hours: 1, minutes: 30), // Đà Nẵng - Hà Nội
    "QH333": const Duration(hours: 1),
    "VJ678": const Duration(hours: 2, minutes: 30),
    "VN555": const Duration(hours: 2, minutes: 10),

    // Quốc tế
    "VN301_intl": const Duration(hours: 3, minutes: 30), // HN - Singapore
    "VJ915": const Duration(hours: 2),
    "VN417": const Duration(hours: 5),
    "QH707": const Duration(hours: 2, minutes: 30),
    "VN923": const Duration(hours: 6, minutes: 30),
    "VJ865": const Duration(hours: 2, minutes: 45),
    "VN931": const Duration(hours: 12, minutes: 30),
    "VN111": const Duration(hours: 8, minutes: 30),
    "VN223": const Duration(hours: 11, minutes: 30),
    "VN441": const Duration(hours: 16),
    "VN575": const Duration(hours: 7, minutes: 30),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  /// Sinh giờ khởi hành
  List<DateTime> generateDepartures(Duration duration) {
    if (duration <= const Duration(hours: 2)) {
      return List.generate(6, (i) => DateTime(2025, 1, 1, 6 + i * 2));
    } else if (duration <= const Duration(hours: 4)) {
      return [
        DateTime(2025, 1, 1, 6),
        DateTime(2025, 1, 1, 12),
        DateTime(2025, 1, 1, 18),
      ];
    } else {
      return [
        DateTime(2025, 1, 1, 8),
        DateTime(2025, 1, 1, 20),
      ];
    }
  }

  /// Sinh vé
  List<Map<String, dynamic>> generateTickets(String flightCode) {
    final duration = flightDurations[flightCode] ?? const Duration(hours: 2);
    final departures = generateDepartures(duration);

    final seatClasses = [
      {"class": "Phổ thông", "multiplier": 1.0},
      {"class": "Phổ thông linh hoạt", "multiplier": 1.3},
      {"class": "Thương gia", "multiplier": 2.5},
      {"class": "Hạng nhất", "multiplier": 4.0},
    ];

    final List<Map<String, dynamic>> tickets = [];
    int idx = 0;
    for (final start in departures) {
      final end = start.add(duration);
      final seat = seatClasses[idx % seatClasses.length];
      final basePrice = 1500000;
      final price = (basePrice * (seat["multiplier"] as num)).toInt();

      tickets.add({
        "id": "$flightCode-V${idx + 1}",
        "start": start,
        "end": end,
        "class": seat["class"],
        "price": price,
        "duration": duration,
      });
      idx++;
    }
    return tickets;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách chuyến bay"),
        backgroundColor: Colors.purple,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Nội địa"),
            Tab(text: "Quốc tế"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFlightList(domesticFlights, dateFormat),
          _buildFlightList(internationalFlights, dateFormat),
        ],
      ),
    );
  }

  Widget _buildFlightList(
      List<Map<String, dynamic>> flights, DateFormat dateFormat) {
    return ListView.builder(
      itemCount: flights.length,
      itemBuilder: (context, index) {
        final flight = flights[index];
        final tickets = generateTickets(flight["flight"]);

        return ExpansionTile(
          leading: const Icon(Icons.flight_takeoff, color: Colors.purple),
          title: Text("${flight["flight"]} - ${flight["route"]}"),
          children: tickets.map((ticket) {
            final hours = ticket["duration"].inHours;
            final minutes = ticket["duration"].inMinutes % 60;
            final durationText =
                minutes > 0 ? "$hours giờ $minutes phút" : "$hours giờ";

            final flightCode = flight["flight"];
            final airlineCode = flightCode.substring(0, 2); // VN, VJ, QH...
            final airlineName = airlines[airlineCode] ?? flightCode;

            return ListTile(
              title: Text(
                "⏰ ${dateFormat.format(ticket["start"])} → ${dateFormat.format(ticket["end"])}",
              ),
              subtitle: Text(
                "🛫 ${ticket["class"]} - 💰 ${formatter.format(ticket["price"])} VND\n"
                "⏳ Thời gian bay: $durationText",
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  final int amount = ticket["price"];
                  if (amount > widget.walletBalance) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("⚠️ Số dư ví không đủ!")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransferMoneyFormScreen(
                        account2: BankAccount2(
                          serviceName: "Đặt vé máy bay",
                          provider: airlineName, // ✅ Hãng thay vì mã
                          detail: "${ticket["class"]} - ${flight["route"]}",
                          accountNumber:
                              "PLANE/${flight["flight"]}/${ticket["id"]}",
                        ),
                        presetAmount: amount,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Đặt vé"),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
