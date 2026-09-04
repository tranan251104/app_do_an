import 'package:app_do_an/core/logging/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/navigator_screen/toll_service_screen.dart';

enum ServiceCategoryAction { preview, toll }

class ServiceCategoryItem {
  final String label;
  final IconData icon;
  final String description;
  final ServiceCategoryAction action;

  const ServiceCategoryItem({
    required this.label,
    required this.icon,
    required this.description,
    this.action = ServiceCategoryAction.preview,
  });
}

class ServiceCategoryScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ServiceCategoryItem> services;

  const ServiceCategoryScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.grid_view_rounded, color: Colors.purple.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Chọn dịch vụ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.08,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final service = services[index];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openService(context, service),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple.shade100),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.purple.shade50,
                          child: Icon(
                            service.icon,
                            color: Colors.purple,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          service.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openService(BuildContext context, ServiceCategoryItem service) {
    AppLogger.action('SERVICE category item selected', {
      'category': title,
      'service': service.label,
      'action': service.action.toString(),
    });

    if (service.action == ServiceCategoryAction.toll) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TollServiceScreen()),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.purple.shade50,
                      child: Icon(service.icon, color: Colors.purple),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        service.label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  service.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Dịch vụ ${service.label} đang được AnPay hoàn thiện.',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('TIẾP TỤC'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
