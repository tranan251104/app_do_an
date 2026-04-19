/*import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/model/transaction.dart';
import 'package:app_do_an/navigator/service/transaction_storage.dart';

class ScheduleTabbar extends StatefulWidget {
  const ScheduleTabbar({super.key});

  @override
  State<ScheduleTabbar> createState() => ScheduleTabbarState();
}

class ScheduleTabbarState extends State<ScheduleTabbar> {
  List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }
  
  // 🔹 Gọi lại mỗi khi quay về tab này
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final txs = await TransactionStorage.getTransactions();
    setState(() => transactions = txs);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử giao dịch"),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: loadTransactions,
        child: transactions.isEmpty
          ? ListView( // 🔥 Trick: ListView rỗng nhưng vẫn cho phép kéo refresh
              children: const [
                SizedBox(
                  height: 400, // để có vùng kéo
                  child: Center(child: Text("Chưa có giao dịch nào")),
                ),
              ],
            )
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];
                return ListTile(
                  leading: Icon(
                    t.amount > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                    color: t.amount > 0 ? Colors.green : Colors.red,
                  ),
                  title: Text(t.title),
                  subtitle: Text(t.time),
                  trailing: Text(
                    "${t.amount > 0 ? "+" : ""}${t.amount} đ",
                    style: TextStyle(
                      color: t.amount > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
       ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleTabbar extends StatefulWidget {
  const ScheduleTabbar({super.key});

  @override
  State<ScheduleTabbar> createState() => ScheduleTabbarState();
}

class ScheduleTabbarState extends State<ScheduleTabbar> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Bạn chưa đăng nhập")),
      );
    }

    final txRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('createdAt', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử giao dịch"),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: txRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Chưa có giao dịch nào"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final amount = data['amount'] ?? 0;
              final title = data['title'] ?? '';
              final ts = data['createdAt'] as Timestamp?;
              final time = ts != null ? ts.toDate().toString() : '';

              return ListTile(
                leading: Icon(
                  amount > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                  color: amount > 0 ? Colors.green : Colors.red,
                ),
                title: Text(title),
                subtitle: Text(time),
                trailing: Text(
                  "${amount > 0 ? "+" : ""}$amount đ",
                  style: TextStyle(
                    color: amount > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


