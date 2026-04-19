import 'package:flutter/material.dart';
import 'package:app_do_an/navigator/model/bankAccount2.dart';
import 'package:app_do_an/navigator/fourth_screen/transfer_money_form_screen.dart';

class RbtSong {
  final String title;
  final String artist;
  final String price;

  RbtSong({required this.title, required this.artist, required this.price});
}

class RbtScreen extends StatefulWidget {
  final int walletBalance; // ✅ truyền từ ngoài vào

  const RbtScreen({super.key, required this.walletBalance});

  @override
  State<RbtScreen> createState() => _RbtScreenState();
}

class _RbtScreenState extends State<RbtScreen> {
  // 🔹 Dữ liệu giả lập
  final Map<String, Map<String, List<RbtSong>>> rbtData = {
    "Viettel iMuzik": {
      "Nhạc trẻ": List.generate(
        10,
        (i) => RbtSong(
          title: "Bài nhạc trẻ ${i + 1}",
          artist: "Ca sĩ trẻ ${i + 1}",
          price: "9,000đ",
        ),
      ),
      "Nhạc remix": List.generate(
        10,
        (i) => RbtSong(
          title: "Bản remix ${i + 1}",
          artist: "DJ ${i + 1}",
          price: "9,000đ",
        ),
      ),
      "Nhạc trữ tình": List.generate(
        10,
        (i) => RbtSong(
          title: "Bài trữ tình ${i + 1}",
          artist: "Ca sĩ trữ tình ${i + 1}",
          price: "9,000đ",
        ),
      ),
      "Nhạc không lời": List.generate(
        10,
        (i) => RbtSong(
          title: "Nhạc cụ không lời ${i + 1}",
          artist: "Instrument ${i + 1}",
          price: "9,000đ",
        ),
      ),
      "Rap/HipHop": List.generate(
        10,
        (i) => RbtSong(
          title: "Track rap ${i + 1}",
          artist: "Rapper ${i + 1}",
          price: "9,000đ",
        ),
      ),
      "Nhạc cách mạng": List.generate(
        10,
        (i) => RbtSong(
          title: "Ca khúc cách mạng ${i + 1}",
          artist: "Nghệ sĩ ${i + 1}",
          price: "Miễn phí",
        ),
      ),
    },
    "Mobifone FunRing": {
      "Nhạc trẻ": List.generate(
        10,
        (i) => RbtSong(
          title: "Mobi Nhạc trẻ ${i + 1}",
          artist: "Ca sĩ ${i + 1}",
          price: "9,000đ",
        ),
      ),
      "Nhạc remix": List.generate(
        10,
        (i) => RbtSong(
          title: "Mobi Remix ${i + 1}",
          artist: "DJ ${i + 1}",
          price: "9,000đ",
        ),
      ),
      "Nhạc trữ tình": List.generate(
        10,
        (i) => RbtSong(
          title: "Mobi Trữ tình ${i + 1}",
          artist: "Ca sĩ ${i + 1}",
          price: "9,000đ",
        ),
      ),
      "Nhạc không lời": List.generate(
        10,
        (i) => RbtSong(
          title: "Mobi Không lời ${i + 1}",
          artist: "Nhạc cụ ${i + 1}",
          price: "9,000đ",
        ),
      ),
      "Rap/HipHop": List.generate(
        10,
        (i) => RbtSong(
          title: "Mobi Rap ${i + 1}",
          artist: "Rapper ${i + 1}",
          price: "9,000đ",
        ),
      ),
    },
    "Vinaphone MyTunes": {
      "Nhạc trẻ": List.generate(
        10,
        (i) => RbtSong(
          title: "Vina Nhạc trẻ ${i + 1}",
          artist: "Ca sĩ ${i + 1}",
          price: "9,000đ",
        ),
      ),
      "Nhạc remix": List.generate(
        10,
        (i) => RbtSong(
          title: "Vina Remix ${i + 1}",
          artist: "DJ ${i + 1}",
          price: "9,000đ",
        ),
      ),
      "Nhạc trữ tình": List.generate(
        10,
        (i) => RbtSong(
          title: "Vina Trữ tình ${i + 1}",
          artist: "Ca sĩ ${i + 1}",
          price: "9,000đ",
        ),
      ),
      "Nhạc cách mạng": List.generate(
        10,
        (i) => RbtSong(
          title: "Vina Cách mạng ${i + 1}",
          artist: "Nghệ sĩ ${i + 1}",
          price: "Miễn phí",
        ),
      ),
      "Rap/HipHop": List.generate(
        10,
        (i) => RbtSong(
          title: "Vina Rap ${i + 1}",
          artist: "Rapper ${i + 1}",
          price: "9,000đ",
        ),
      ),
    },
  };

  String selectedCategory = "Nhạc trẻ";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: rbtData.keys.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Dịch vụ Nhạc chờ"),
          backgroundColor: Colors.purple,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Viettel iMuzik"),
              Tab(text: "Mobifone FunRing"),
              Tab(text: "Vinaphone MyTunes"),
            ],
          ),
        ),
        body: TabBarView(
          children: rbtData.entries.map((entry) {
            final provider = entry.key;
            final categories = entry.value;
            if (!categories.containsKey(selectedCategory)) {
              selectedCategory = categories.keys.first;
            }

            return Column(
              children: [
                // 🔹 Dropdown chọn thể loại
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: categories.keys
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedCategory = val!;
                      });
                    },
                  ),
                ),

                // 🔹 Danh sách bài hát
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: categories[selectedCategory]!
                        .map((song) => Card(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Thông tin bài hát
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(song.title,
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold)),
                                          Text("Ca sĩ: ${song.artist}"),
                                          Text("Giá: ${song.price}"),
                                        ],
                                      ),
                                    ),

                                    // Nút nghe thử
                                    IconButton(
                                      icon: const Icon(Icons.play_arrow,
                                          color: Colors.green),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Đang phát thử '${song.title}'...")));
                                      },
                                    ),

                                    // Nút đăng ký
                                    ElevatedButton(
                                      onPressed: () {
                                        final cleanPrice = song.price
                                            .replaceAll(RegExp(r'[^0-9]'), '');
                                        final amount =
                                            int.tryParse(cleanPrice) ?? 0;

                                        if (amount > 0 &&
                                            amount >
                                                widget.walletBalance) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "❌ Số dư ví không đủ để đăng ký bài hát này"),
                                            ),
                                          );
                                          return;
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                TransferMoneyFormScreen(
                                              account2: BankAccount2(
                                                serviceName: "Nhạc chờ",
                                                provider: provider,
                                                detail: song.title,
                                                accountNumber:
                                                    "RBT/$provider/${song.title}",
                                              ),
                                              presetAmount: amount,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple,
                                      ),
                                      child: const Text("Đăng ký"),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
