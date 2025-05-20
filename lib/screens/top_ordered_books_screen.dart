import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TopOrderedBooksScreen extends StatefulWidget {
  const TopOrderedBooksScreen({Key? key}) : super(key: key);

  @override
  State<TopOrderedBooksScreen> createState() => _TopOrderedBooksScreenState();
}

class _TopOrderedBooksScreenState extends State<TopOrderedBooksScreen> {
  bool isLoading = true;
  Map<String, Map<String, dynamic>> bookOrderMap = {};

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _loadTopOrderedBooks();
  }

  Future<void> _loadTopOrderedBooks() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('orders').get();

      Map<String, Map<String, dynamic>> tempMap = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        if (data.containsKey('items')) {
          List items = data['items'];

          for (var item in items) {
            String title = item['title'] ?? 'Không tên';
            String imageUrl = item['imageUrl'] ?? '';
            int price = (item['price'] ?? 0).toInt();
            int quantity = (item['quantity'] ?? 1).toInt();

            if (tempMap.containsKey(title)) {
              tempMap[title]!['quantity'] += quantity;
            } else {
              tempMap[title] = {
                'imageUrl': imageUrl,
                'price': price,
                'quantity': quantity,
              };
            }
          }
        }
      }

      // Sắp xếp theo số lượng giảm dần
      var sortedEntries = tempMap.entries.toList()
        ..sort((a, b) => b.value['quantity'].compareTo(a.value['quantity']));

      setState(() {
        bookOrderMap = Map.fromEntries(sortedEntries);
        isLoading = false;
      });
    } catch (e) {
      print("Lỗi tải dữ liệu sách: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Sách được đặt nhiều nhất")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Sách được đặt nhiều nhất")),
      body: ListView.builder(
        itemCount: bookOrderMap.length,
        itemBuilder: (context, index) {
          String title = bookOrderMap.keys.elementAt(index);
          final data = bookOrderMap[title]!;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: data['imageUrl'] != ''
                    ? Image.network(
                        data['imageUrl'],
                        width: 60,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 60),
                      )
                    : const Icon(Icons.book, size: 60),
              ),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                'Giá: ${currencyFormatter.format(data['price'])}\nSố lượng đặt: ${data['quantity']}',
                style: const TextStyle(fontSize: 14),
              ),
              trailing: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
