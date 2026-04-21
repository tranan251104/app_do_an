import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'generic_travel_result_screen.dart';

class GenericTravelSearchScreen extends StatefulWidget {
  final String title;
  final String type; // 'plane', 'train', 'bus'

  const GenericTravelSearchScreen({super.key, required this.title, required this.type});

  @override
  State<GenericTravelSearchScreen> createState() => _GenericTravelSearchScreenState();
}

class _GenericTravelSearchScreenState extends State<GenericTravelSearchScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputCard("Điểm đi", Icons.location_on_outlined, _fromController),
            const SizedBox(height: 12),
            _buildInputCard("Điểm đến", Icons.location_on, _toController),
            const SizedBox(height: 12),
            ListTile(
              tileColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.calendar_today, color: Colors.purple),
              title: const Text("Ngày đi"),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (_fromController.text.isEmpty || _toController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vui lòng nhập đầy đủ điểm đi và điểm đến")),
                  );
                  return;
                }

                // 🔹 Mở màn hình danh sách chuyến đi
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenericTravelResultScreen(
                      title: widget.title,
                      type: widget.type,
                      from: _fromController.text,
                      to: _toController.text,
                      date: DateFormat('dd/MM/yyyy').format(_selectedDate),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("TÌM CHUYẾN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(String label, IconData icon, TextEditingController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.purple),
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
