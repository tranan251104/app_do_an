import 'package:app_do_an/navigator/third_screen/bank_account_screen.dart';
import 'package:flutter/material.dart';


class TransferMoneyScreen extends StatefulWidget {
  const TransferMoneyScreen({super.key});

  @override
  State<TransferMoneyScreen> createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen>
  with SingleTickerProviderStateMixin {
    late TabController _tabController;

    @override
    void initState() {
      super.initState();
      _tabController = TabController(length: 2, vsync: this);
    }

    @override
    void dispose() {
      _tabController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Chuyển tiền"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: Column(
          children: [
            // Dòng các chức năng
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionButton(Icons.account_balance_wallet, "Ví ShopeePay", (){}),
                  _actionButton(Icons.qr_code_scanner, "Quét QR", (){}),
                  _actionButton(Icons.account_balance, "Rút tiền", (){}),
                  _actionButton(Icons.card_giftcard, "Gửi Lì Xì", (){}),
                  _actionButton(Icons.account_balance_outlined, "Đến Ngân hàng", () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BankAccountScreen(),
                      ),
                    );

                    if (result == true) {
                      Navigator.pop(context, true); // báo tiếp cho HomeTabbar
                    }
                  }),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.purple,
                unselectedLabelColor: Colors.black54,
                indicatorColor: Colors.purple,
                tabs: const [
                  Tab(text: "Người nhận gần đây"),
                  Tab(text: "Mục yêu thích"),
                ],
              ),
            ),

            // Nội dung Tab
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _emptyState("Không tìm thấy người nhận gần đây",
                    "Hãy thực hiện giao dịch chuyển tiền nhé!"),
                  _emptyState("Chưa có mục yêu thích",
                    "Hãy thêm người nhận vào danh sách yêu thích để tiện giao dịch!"),
                ],
              ),
            ),
          ],
        ),
      );
    }
    /// Widget nút hành động
    Widget _actionButton(IconData icon, String label, VoidCallback? onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.red.shade50,
              child: Icon(icon, size: 28, color: Colors.purple),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            )
          ],
        ),
      );
    }


  /// Widget hiển thị trạng thái trống
  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
