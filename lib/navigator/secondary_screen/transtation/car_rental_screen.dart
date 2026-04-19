import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';

class CarRentalScreen extends StatefulWidget {
  final int walletBalance;
  const CarRentalScreen({super.key, required this.walletBalance});

  @override
  State<CarRentalScreen> createState() => _CarRentalScreenState();
}

class _CarRentalScreenState extends State<CarRentalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final formatter = NumberFormat("#,###", "vi_VN");

  /// Dataset gần thực tế: mỗi loại xe 20–30 cái
  final Map<String, List<Map<String, dynamic>>> rentalCars = {
    "Xe máy": [
      {"name": "Honda AirBlade 2023", "seats": 2, "gear": "Ga", "price": 200000, "provider": "GreenCar Rental"},
      {"name": "Honda SH 150i", "seats": 2, "gear": "Ga", "price": 250000, "provider": "Hanoi Moto Rent"},
      {"name": "Honda Vision", "seats": 2, "gear": "Ga", "price": 180000, "provider": "SaigonBike"},
      {"name": "Honda Winner X", "seats": 2, "gear": "Số", "price": 220000, "provider": "VietMoto"},
      {"name": "Yamaha Exciter 155", "seats": 2, "gear": "Số", "price": 200000, "provider": "GoMoto"},
      {"name": "Yamaha Janus", "seats": 2, "gear": "Ga", "price": 170000, "provider": "EcoBike"},
      {"name": "Vespa Primavera", "seats": 2, "gear": "Ga", "price": 280000, "provider": "Hertz Bike"},
      {"name": "Suzuki Raider", "seats": 2, "gear": "Số", "price": 210000, "provider": "RentalHub"},
      {"name": "Honda PCX", "seats": 2, "gear": "Ga", "price": 240000, "provider": "MotoKing"},
      {"name": "Yamaha NVX", "seats": 2, "gear": "Ga", "price": 230000, "provider": "SaigonBike"},
      {"name": "SYM Elegant", "seats": 2, "gear": "Số", "price": 150000, "provider": "EcoBike"},
      {"name": "Honda Future", "seats": 2, "gear": "Số", "price": 160000, "provider": "GoMoto"},
      {"name": "Vespa Sprint", "seats": 2, "gear": "Ga", "price": 300000, "provider": "Hanoi Moto Rent"},
      {"name": "Honda Lead", "seats": 2, "gear": "Ga", "price": 200000, "provider": "RentalHub"},
      {"name": "Yamaha Latte", "seats": 2, "gear": "Ga", "price": 190000, "provider": "EcoBike"},
      {"name": "Honda Wave RSX", "seats": 2, "gear": "Số", "price": 140000, "provider": "VietMoto"},
      {"name": "Honda SH Mode", "seats": 2, "gear": "Ga", "price": 270000, "provider": "SaigonBike"},
      {"name": "Yamaha Grande", "seats": 2, "gear": "Ga", "price": 220000, "provider": "GoMoto"},
      {"name": "Honda Cub 125", "seats": 2, "gear": "Số", "price": 160000, "provider": "GreenCar Rental"},
      {"name": "Honda CBR150R", "seats": 2, "gear": "Số", "price": 300000, "provider": "Hertz Bike"},
    ],
    "4 chỗ": [
      {"name": "Toyota Vios", "seats": 4, "gear": "Tự động", "price": 700000, "provider": "Avis"},
      {"name": "Hyundai Accent", "seats": 4, "gear": "Tự động", "price": 750000, "provider": "GreenCar Rental"},
      {"name": "Mazda 3", "seats": 4, "gear": "Tự động", "price": 900000, "provider": "SaigonCar"},
      {"name": "Kia Morning", "seats": 4, "gear": "Số", "price": 500000, "provider": "EcoCar"},
      {"name": "VinFast Lux A2.0", "seats": 4, "gear": "Tự động", "price": 1200000, "provider": "VinFast Rent"},
      {"name": "Honda City", "seats": 4, "gear": "Tự động", "price": 800000, "provider": "RentalHub"},
      {"name": "Toyota Altis", "seats": 4, "gear": "Tự động", "price": 950000, "provider": "Avis"},
      {"name": "Hyundai Elantra", "seats": 4, "gear": "Tự động", "price": 850000, "provider": "EcoCar"},
      {"name": "Mazda 2", "seats": 4, "gear": "Tự động", "price": 820000, "provider": "GoCar"},
      {"name": "Ford Focus", "seats": 4, "gear": "Tự động", "price": 880000, "provider": "Hertz"},
      {"name": "Kia Cerato", "seats": 4, "gear": "Tự động", "price": 860000, "provider": "Avis"},
      {"name": "VinFast Fadil", "seats": 4, "gear": "Tự động", "price": 600000, "provider": "VinFast Rent"},
      {"name": "Hyundai i10", "seats": 4, "gear": "Số", "price": 550000, "provider": "EcoCar"},
      {"name": "Toyota Yaris", "seats": 4, "gear": "Tự động", "price": 870000, "provider": "GreenCar Rental"},
      {"name": "Honda Civic", "seats": 4, "gear": "Tự động", "price": 1100000, "provider": "SaigonCar"},
      {"name": "Mazda 6", "seats": 4, "gear": "Tự động", "price": 1250000, "provider": "GoCar"},
      {"name": "Toyota Camry", "seats": 4, "gear": "Tự động", "price": 1400000, "provider": "Hertz"},
      {"name": "Kia K3", "seats": 4, "gear": "Tự động", "price": 900000, "provider": "EcoCar"},
      {"name": "Hyundai Sonata", "seats": 4, "gear": "Tự động", "price": 1350000, "provider": "Avis"},
      {"name": "VinFast VF5", "seats": 4, "gear": "Điện", "price": 1500000, "provider": "VinFast Rent"},
    ],
    "7 chỗ": [
      {"name": "Toyota Innova", "seats": 7, "gear": "Tự động", "price": 1000000, "provider": "Avis"},
      {"name": "Mitsubishi Xpander", "seats": 7, "gear": "Tự động", "price": 950000, "provider": "EcoCar"},
      {"name": "Toyota Fortuner", "seats": 7, "gear": "Tự động", "price": 1300000, "provider": "GreenCar Rental"},
      {"name": "Kia Rondo", "seats": 7, "gear": "Số", "price": 850000, "provider": "SaigonCar"},
      {"name": "Hyundai Stargazer", "seats": 7, "gear": "Tự động", "price": 980000, "provider": "GoCar"},
      {"name": "Suzuki Ertiga", "seats": 7, "gear": "Số", "price": 800000, "provider": "EcoCar"},
      {"name": "Mazda CX-8", "seats": 7, "gear": "Tự động", "price": 1400000, "provider": "Avis"},
      {"name": "Kia Carnival", "seats": 7, "gear": "Tự động", "price": 1600000, "provider": "Hertz"},
      {"name": "Toyota Avanza", "seats": 7, "gear": "Số", "price": 820000, "provider": "SaigonCar"},
      {"name": "Honda BR-V", "seats": 7, "gear": "Tự động", "price": 1000000, "provider": "GoCar"},
      {"name": "Chevrolet Orlando", "seats": 7, "gear": "Tự động", "price": 950000, "provider": "RentalHub"},
      {"name": "Mitsubishi Pajero Sport", "seats": 7, "gear": "Tự động", "price": 1500000, "provider": "EcoCar"},
      {"name": "Hyundai SantaFe 7 chỗ", "seats": 7, "gear": "Tự động", "price": 1700000, "provider": "GreenCar Rental"},
      {"name": "Kia Sorento", "seats": 7, "gear": "Tự động", "price": 1600000, "provider": "Avis"},
      {"name": "Toyota Rush", "seats": 7, "gear": "Số", "price": 880000, "provider": "SaigonCar"},
      {"name": "Ford Everest 7 chỗ", "seats": 7, "gear": "Tự động", "price": 1800000, "provider": "GoCar"},
      {"name": "Isuzu mu-X", "seats": 7, "gear": "Tự động", "price": 1450000, "provider": "RentalHub"},
      {"name": "Nissan Terra", "seats": 7, "gear": "Tự động", "price": 1500000, "provider": "EcoCar"},
      {"name": "VinFast Lux SA2.0", "seats": 7, "gear": "Tự động", "price": 1700000, "provider": "VinFast Rent"},
      {"name": "Peugeot 5008", "seats": 7, "gear": "Tự động", "price": 1750000, "provider": "Avis"},
    ],
    "SUV": [
      {"name": "Mazda CX-5", "seats": 5, "gear": "Tự động", "price": 1500000, "provider": "GreenCar Rental"},
      {"name": "Hyundai SantaFe", "seats": 7, "gear": "Tự động", "price": 1600000, "provider": "Avis"},
      {"name": "Ford Everest", "seats": 7, "gear": "Tự động", "price": 1700000, "provider": "EcoCar"},
      {"name": "VinFast VF8", "seats": 5, "gear": "Điện", "price": 2000000, "provider": "VinFast Rent"},
      {"name": "Toyota Land Cruiser Prado", "seats": 7, "gear": "Tự động", "price": 3000000, "provider": "Avis"},
      {"name": "Kia Sportage", "seats": 5, "gear": "Tự động", "price": 1500000, "provider": "EcoCar"},
      {"name": "Hyundai Tucson", "seats": 5, "gear": "Tự động", "price": 1450000, "provider": "RentalHub"},
      {"name": "Mitsubishi Outlander", "seats": 5, "gear": "Tự động", "price": 1400000, "provider": "GoCar"},
      {"name": "Honda CR-V", "seats": 5, "gear": "Tự động", "price": 1600000, "provider": "GreenCar Rental"},
      {"name": "Peugeot 3008", "seats": 5, "gear": "Tự động", "price": 1700000, "provider": "Avis"},
      {"name": "VinFast VF9", "seats": 7, "gear": "Điện", "price": 2500000, "provider": "VinFast Rent"},
      {"name": "BMW X3", "seats": 5, "gear": "Tự động", "price": 3500000, "provider": "Hertz"},
      {"name": "Mercedes GLC 300", "seats": 5, "gear": "Tự động", "price": 4000000, "provider": "Avis"},
      {"name": "Audi Q5", "seats": 5, "gear": "Tự động", "price": 3800000, "provider": "EcoCar"},
      {"name": "Volvo XC60", "seats": 5, "gear": "Tự động", "price": 3700000, "provider": "GoCar"},
      {"name": "Lexus RX350", "seats": 5, "gear": "Tự động", "price": 4500000, "provider": "Avis"},
      {"name": "Range Rover Evoque", "seats": 5, "gear": "Tự động", "price": 5000000, "provider": "Hertz"},
      {"name": "Porsche Cayenne", "seats": 5, "gear": "Tự động", "price": 7000000, "provider": "Avis"},
      {"name": "Tesla Model X", "seats": 7, "gear": "Điện", "price": 6000000, "provider": "EcoCar"},
      {"name": "Lamborghini Urus", "seats": 5, "gear": "Tự động", "price": 15000000, "provider": "SaigonCar"},
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: rentalCars.keys.length, vsync: this);
  }

  Future<void> _bookCar(Map<String, dynamic> car) async {
    int selectedDays = 1; // mặc định thuê 1 ngày

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Chọn số ngày thuê"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<int>(
                value: selectedDays,
                items: List.generate(30, (i) => i + 1)
                    .map((day) => DropdownMenuItem(
                          value: day,
                          child: Text("$day ngày"),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedDays = value);
                  }
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedDays),
              child: const Text("Xác nhận"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final total = result * car["price"];

      if (total > widget.walletBalance) {
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
              serviceName: "Thuê xe tự lái",
              provider: car["provider"], // ✅ lấy từ dataset
              detail: "${car["name"]} - $result ngày",
              accountNumber: "RENTAL/${car["name"].replaceAll(" ", "_")}",
            ),
            presetAmount: total.toInt(),
          ),
        ),
      );
    }
  }

  Widget _buildCarItem(Map<String, dynamic> car) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          car["seats"] == 2 ? Icons.motorcycle : Icons.directions_car,
          size: 36,
          color: Colors.purple,
        ),
        title: Text(car["name"],
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: Text(
          "🚘 ${car["seats"]} chỗ | ⚙️ ${car["gear"]}\n"
          "💰 ${formatter.format(car["price"])} VND / ngày\n"
          "🏢 Công ty: ${car["provider"]}",
        ),
        trailing: ElevatedButton(
          onPressed: () => _bookCar(car),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text("Thuê"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thuê xe tự lái"),
        backgroundColor: Colors.purple,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: rentalCars.keys.map((type) => Tab(text: type)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: rentalCars.entries.map((entry) {
          final cars = entry.value;

          // ✅ Tab Xe máy => chia 2 nhóm
          if (entry.key == "Xe máy") {
            final xeGa = cars.where((c) => c["gear"] == "Ga").toList();
            final xeSo = cars.where((c) => c["gear"] == "Số").toList();

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                ExpansionTile(
                  title: const Text("Xe ga",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  children: xeGa.map((car) => _buildCarItem(car)).toList(),
                ),
                ExpansionTile(
                  title: const Text("Xe số",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  children: xeSo.map((car) => _buildCarItem(car)).toList(),
                ),
              ],
            );
          }

          // ✅ Các loại xe khác (4 chỗ, 7 chỗ, SUV...)
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return _buildCarItem(car);
            },
          );
        }).toList(),
      ),
    );
  }
}
