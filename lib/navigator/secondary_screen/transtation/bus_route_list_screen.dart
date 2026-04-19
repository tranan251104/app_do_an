import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';

class BusTicketFilterScreen extends StatefulWidget {
  final int walletBalance;
  const BusTicketFilterScreen({super.key, required this.walletBalance});

  @override
  State<BusTicketFilterScreen> createState() => _BusTicketFilterScreenState();
}

class _BusTicketFilterScreenState extends State<BusTicketFilterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final formatter = NumberFormat("#,###", "vi_VN");

  // 🔽 Danh sách 26 tuyến xe khách (có thể mở rộng thêm)
  final List<Map<String, dynamic>> busRoutes = [
    {
      "route": "Hà Nội → Hải Phòng",
      "duration": const Duration(hours: 2),
      "providers": {
        "Limousine": [
          {"name": "Hoàng Long", "departures": ["08:00", "20:00"]},
          {"name": "Anh Huy", "departures": ["09:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Mai Linh", "departures": ["07:00", "13:00", "18:00"]},
          {"name": "OHo", "departures": ["09:00", "12:00", "16:00"]}
        ],
        "Giường nằm": [
          {"name": "Phúc Xuyên", "departures": ["21:00"]}
        ]
      }
    },
    {
      "route": "Hà Nội → Ninh Bình",
      "duration": const Duration(hours: 2, minutes: 30),
      "providers": {
        "Limousine": [
          {"name": "X.E Ninh Bình", "departures": ["08:00", "14:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Cúc Tùng", "departures": ["09:00", "15:00"]},
          {"name": "Minh Sơn", "departures": ["07:00", "16:00"]}
        ],
        "Giường nằm": [
          {"name": "Kumho Việt Thanh", "departures": ["20:00"]}
        ]
      }
    },
    {
      "route": "Hà Nội → Thanh Hóa",
      "duration": const Duration(hours: 3),
      "providers": {
        "Limousine": [
          {"name": "Sao Việt", "departures": ["07:00", "19:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Mai Linh", "departures": ["09:00", "15:00"]}
        ],
        "Giường nằm": [
          {"name": "Hoàng Long", "departures": ["21:00"]},
          {"name": "Anh Dũng", "departures": ["21:00"]}
        ]
      }
    },
    {
      "route": "Hà Nội → Nghệ An",
      "duration": const Duration(hours: 5),
      "providers": {
        "Limousine": [
          {"name": "Camel Travel", "departures": ["06:00"]},
          {"name": "Xứ Nghệ travel", "departures": ["14:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Hồng Vinh", "departures": ["08:00", "14:00"]}
        ],
        "Giường nằm": [
          {"name": "Tuấn Thành", "departures": ["20:00"]},
          {"name": "Anh Phong", "departures": ["20:00"]},
        ]
      }
    },
    {
      "route": "Hà Nội → Hà Giang",
      "duration": const Duration(hours: 7),
      "providers": {
        "Limousine": [
          {"name": "Quang Nghị", "departures": ["06:00", "18:00"]},
          {"name": "Hảo Minh", "departures": ["13:00"]},
        ],
        "Ghế ngồi": [
          {"name": "Ngọc Cường", "departures": ["07:00"]}
        ],
        "Giường nằm": [
          {"name": "Cầu Mè", "departures": ["21:00"]}
        ]
      }
    },
    {
      "route": "Hà Nội → Lào Cai",
      "duration": const Duration(hours: 6),
      "providers": {
        "Limousine": [
          {"name": "Sapa Express", "departures": ["07:00", "15:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Việt Bus", "departures": ["09:00"]}
        ],
        "Giường nằm": [
          {"name": "Hải Vân", "departures": ["20:00"]}
        ]
      }
    },
    {
      "route": "Hà Nội → Quảng Ninh",
      "duration": const Duration(hours: 4),
      "providers": {
        "Limousine": [
          {"name": "Hạ Long Travel", "departures": ["08:00"]},
          {"name": "Anh Tuấn Travel", "departures": ["16:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Phúc Xuyên", "departures": ["09:00", "17:00"]}
        ],
        "Giường nằm": [
          {"name": "Ka Long", "departures": ["22:00"]}
        ]
      }
    },
    {
      "route": "Hà Nội → Sơn La",
      "duration": const Duration(hours: 8),
      "providers": {
        "Limousine": [
          {"name": "Hải Nam", "departures": ["06:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Sơn La Express", "departures": ["07:00"]}
        ],
        "Giường nằm": [
          {"name": "Thành Hưng", "departures": ["20:00"]}
        ]
      }
    },
    {
      "route": "Hà Nội → Điện Biên",
      "duration": const Duration(hours: 10),
      "providers": {
        "Limousine": [
          {"name": "Điện Biên Travel", "departures": ["05:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Xuân Long", "departures": ["07:00"]}
        ],
        "Giường nằm": [
          {"name": "Trung Kiên", "departures": ["18:00"]}
        ]
      }
    },
    {
      "route": "Hà Nội → Huế",
      "duration": const Duration(hours: 14),
      "providers": {
        "Limousine": [
          {"name": "An Phú Travel", "departures": ["06:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Hưng Thành", "departures": ["07:00"]}
        ],
        "Giường nằm": [
          {"name": "Camel Travel", "departures": ["20:00"]}
        ]
      }
    },
    {
      "route": "Hà Nội → Đà Nẵng",
      "duration": const Duration(hours: 16),
      "providers": {
        "Limousine": [
          {"name": "Phúc Thuận Thảo", "departures": ["08:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Mai Linh", "departures": ["10:00"]}
        ],
        "Giường nằm": [
          {"name": "Hoàng Long", "departures": ["20:00"]}
        ]
      }
    },
    {
      "route": "Hà Nội → Nha Trang",
      "duration": const Duration(hours: 20),
      "providers": {
        "Limousine": [
          {"name": "Phương Trang", "departures": ["07:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Xe Việt Nhật", "departures": ["09:00"]}
        ],
        "Giường nằm": [
          {"name": "Hưng Thịnh", "departures": ["19:00"]}
        ]
      }
    },
    {
      "route": "Hà Nội → Sài Gòn",
      "duration": const Duration(hours: 28),
      "providers": {
        "Limousine": [
          {"name": "Xe Bắc Nam", "departures": ["06:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Mai Linh", "departures": ["08:00"]}
        ],
        "Giường nằm": [
          {"name": "Thành Bưởi", "departures": ["20:00"]}
        ]
      }
    },
    {
      "route": "Sài Gòn → Vũng Tàu",
      "duration": const Duration(hours: 2, minutes: 30),
      "providers": {
        "Limousine": [
          {"name": "Hoa Mai", "departures": ["06:00", "18:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Toàn Thắng", "departures": ["07:00"]}
        ],
        "Giường nằm": [
          {"name": "Phương Trang", "departures": ["08:00", "20:00"]}
        ]
      }
    },
    {
      "route": "Sài Gòn → Cần Thơ",
      "duration": const Duration(hours: 4),
      "providers": {
        "Limousine": [
          {"name": "Trung Nguyên", "departures": ["07:00",]},
          {"name": "Cần Thơ travel", "departures": ["13:00",]}
        ],
        "Ghế ngồi": [
          {"name": "Mai Linh", "departures": ["09:00"]}
        ],
        "Giường nằm": [
          {"name": "Phương Trang", "departures": ["20:00"]}
        ]
      }
    },
    {
      "route": "Sài Gòn → Đà Lạt",
      "duration": const Duration(hours: 6),
      "providers": {
        "Limousine": [
          {"name": "Thành Bưởi", "departures": ["08:00", "22:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Mai Linh", "departures": ["09:00"]}
        ],
        "Giường nằm": [
          {"name": "Phương Trang", "departures": ["20:00"]}
        ]
      }
    },
    {
      "route": "Sài Gòn → Nha Trang",
      "duration": const Duration(hours: 9),
      "providers": {
        "Limousine": [
          {"name": "Kumho", "departures": ["06:00", "12:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Mai Linh", "departures": ["07:00"]}
        ],
        "Giường nằm": [
          {"name": "Phương Trang", "departures": ["19:00"]}
        ]
      }
    },
    {
      "route": "Sài Gòn → Phan Thiết",
      "duration": const Duration(hours: 5),
      "providers": {
        "Limousine": [
          {"name": "Hạnh Cafe", "departures": ["07:00", "14:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Mai Linh", "departures": ["09:00"]}
        ],
        "Giường nằm": [
          {"name": "Phương Trang", "departures": ["20:00"]}
        ]
      }
    },
    {
      "route": "Sài Gòn → Buôn Ma Thuột",
      "duration": const Duration(hours: 10),
      "providers": {
        "Limousine": [
          {"name": "Kim Anh", "departures": ["06:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Mai Linh", "departures": ["07:00"]}
        ],
        "Giường nằm": [
          {"name": "Phương Trang", "departures": ["19:00"]}
        ]
      }
    },
    {
      "route": "Sài Gòn → Pleiku",
      "duration": const Duration(hours: 12),
      "providers": {
        "Limousine": [
          {"name": "Minh Quốc", "departures": ["07:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Phương Trang", "departures": ["09:00"]}
        ],
        "Giường nằm": [
          {"name": "Việt Tân", "departures": ["19:00"]}
        ]
      }
    },
    {
      "route": "Sài Gòn → Quy Nhơn",
      "duration": const Duration(hours: 14),
      "providers": {
        "Limousine": [
          {"name": "Hải Âu", "departures": ["06:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Kumho", "departures": ["09:00"]}
        ],
        "Giường nằm": [
          {"name": "Mai Linh", "departures": ["19:00"]}
        ]
      }
    },
    {
      "route": "Sài Gòn → Huế",
      "duration": const Duration(hours: 20),
      "providers": {
        "Limousine": [
          {"name": "Phương Trang", "departures": ["08:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Mai Linh", "departures": ["09:00"]}
        ],
        "Giường nằm": [
          {"name": "Hoàng Long", "departures": ["19:00"]}
        ]
      }
    },
    {
      "route": "Sài Gòn → Đà Nẵng",
      "duration": const Duration(hours: 18),
      "providers": {
        "Limousine": [
          {"name": "An Phú Travel", "departures": ["06:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Hưng Thành", "departures": ["07:00"]}
        ],
        "Giường nằm": [
          {"name": "Phúc Thuận Thảo", "departures": ["19:00"]}
        ]
      }
    },
    {
      "route": "Sài Gòn → Hà Nội",
      "duration": const Duration(hours: 30),
      "providers": {
        "Limousine": [
          {"name": "Xe Bắc Nam", "departures": ["06:00"]}
        ],
        "Ghế ngồi": [
          {"name": "Mai Linh", "departures": ["08:00"]}
        ],
        "Giường nằm": [
          {"name": "Thành Bưởi", "departures": ["20:00"]}
        ]
      }
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  /// Sinh vé theo loại xe
  List<Map<String, dynamic>> generateTickets(String type) {
    final List<Map<String, dynamic>> tickets = [];
    final basePrice = {
      "Limousine": 300000,
      "Ghế ngồi": 150000,
      "Giường nằm": 200000,
    };

    for (final entry in busRoutes) {
      final route = entry["route"];
      final duration = entry["duration"] as Duration;
      final providers = entry["providers"][type] as List;

      for (final provider in providers) {
        final String name = provider["name"];
        final List<String> departures = List<String>.from(provider["departures"]);

        for (final dep in departures) {
          final parts = dep.split(":");
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final start = DateTime(2025, 1, 1, hour, minute);
          final end = start.add(duration);

          tickets.add({
            "id": "$type-${tickets.length + 1}",
            "route": route,
            "class": type,
            "start": start,
            "end": end,
            "provider": name,
            "price": basePrice[type]! + (tickets.length * 5000),
            "duration": duration,
          });
        }
      }
    }
    return tickets;
  }

  void _bookTicket(Map<String, dynamic> ticket) {
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
            serviceName: "Đặt vé xe khách",
            provider: ticket["provider"],
            detail: "${ticket["class"]} - ${ticket["route"]}",
            accountNumber: "BUS/${ticket["id"]}",
          ),
          presetAmount: amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd/MM/yyyy HH:mm");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đặt vé xe khách"),
        backgroundColor: Colors.purple,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Limousine"),
            Tab(text: "Ghế ngồi"),
            Tab(text: "Giường nằm"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTicketList(generateTickets("Limousine"), dateFormat),
          _buildTicketList(generateTickets("Ghế ngồi"), dateFormat),
          _buildTicketList(generateTickets("Giường nằm"), dateFormat),
        ],
      ),
    );
  }

  Widget _buildTicketList(
      List<Map<String, dynamic>> tickets, DateFormat dateFormat) {
    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        final hours = ticket["duration"].inHours;
        final minutes = ticket["duration"].inMinutes % 60;
        final durationText =
            minutes > 0 ? "$hours giờ $minutes phút" : "$hours giờ";

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: ListTile(
            title: Text(ticket["route"]),
            subtitle: Text(
              "⏰ ${dateFormat.format(ticket["start"])} → ${dateFormat.format(ticket["end"])}\n"
              "🚌 ${ticket["class"]} - 💰 ${formatter.format(ticket["price"])} VND\n"
              "🏢 Nhà xe: ${ticket["provider"]}\n"
              "⏳ Thời gian: $durationText",
            ),
            isThreeLine: true,
            trailing: ElevatedButton(
              onPressed: () => _bookTicket(ticket),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Đặt vé"),
            ),
          ),
        );
      },
    );
  }
}
