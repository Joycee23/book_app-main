import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AdminTopSellingScreen extends StatefulWidget {
  const AdminTopSellingScreen({Key? key}) : super(key: key);

  @override
  State<AdminTopSellingScreen> createState() => _AdminTopSellingScreenState();
}

class _AdminTopSellingScreenState extends State<AdminTopSellingScreen> {
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
            int price = 0;
            int quantity = 0;

            if (item['price'] is int) {
              price = item['price'];
            } else if (item['price'] is double) {
              price = (item['price'] as double).toInt();
            }

            if (item['quantity'] is int) {
              quantity = item['quantity'];
            } else if (item['quantity'] is double) {
              quantity = (item['quantity'] as double).toInt();
            }

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

  List<BarChartGroupData> _buildBarChartGroups() {
    List<BarChartGroupData> groups = [];
    int maxItems = 7;

    final entries = bookOrderMap.entries.take(maxItems).toList();

    for (int i = 0; i < entries.length; i++) {
      final quantity = entries[i].value['quantity'] as int;
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: quantity.toDouble(),
              color: Colors.blue,
              width: 20,
              borderRadius: BorderRadius.circular(6),
            )
          ],
        ),
      );
    }
    return groups;
  }

  Widget _buildBarChart() {
    if (bookOrderMap.isEmpty) {
      return const Center(child: Text("Chưa có dữ liệu để hiển thị biểu đồ"));
    }

    final maxQuantity = bookOrderMap.values
        .map<int>((e) => e['quantity'] as int)
        .reduce((value, element) => value > element ? value : element);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: AspectRatio(
        aspectRatio: 1.5,
        child: BarChart(
          BarChartData(
            maxY: maxQuantity.toDouble() + 5,
            barGroups: _buildBarChartGroups(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false, // Ẩn tên sản phẩm ở trục X
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: maxQuantity > 5 ? maxQuantity / 5 : 1,
                ),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quản lý sản phẩm bán chạy")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (bookOrderMap.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quản lý sản phẩm bán chạy")),
        body: const Center(child: Text("Chưa có dữ liệu để hiển thị biểu đồ")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý sản phẩm bán chạy")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBarChart(),
            const Divider(thickness: 1),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
          ],
        ),
      ),
    );
  }
}
