import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/secondary_screen/bill/generic_bill_screen.dart';
import 'package:app_do_an/navigator/service/app_data.dart';

class BillScreen extends StatelessWidget {
  const BillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán hóa đơn"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppData.billServices.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final service = AppData.billServices[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenericBillScreen(
                      title: service['title'],
                      inputLabel: service['inputLabel'],
                      hintText: service['hint'],
                      serviceType: service['type'],
                      providers: List<String>.from(service['providers']),
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(service['icon'], size: 50, color: Colors.purple),
                  const SizedBox(height: 12),
                  Text(service['label'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
