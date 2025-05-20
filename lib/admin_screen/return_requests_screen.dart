import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReturnRequestsScreen extends StatelessWidget {
  const ReturnRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('return_requests')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Lỗi khi tải dữ liệu trả hàng"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text("Chưa có đơn trả hàng nào."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            final name = data['name'] ?? 'Không rõ';
            final phone = data['phone'] ?? 'N/A';
            final address = data['address'] ?? 'Chưa có địa chỉ';
            final product = data['product'] ?? 'Không xác định';
            final reason = data['reason'] ?? 'Không có lý do';
            final status = data['status'] ?? 'Chưa xử lý';
            final timestamp = data['timestamp'] as Timestamp?;
            final formattedDate = timestamp != null
                ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp.toDate())
                : 'Chưa có thời gian';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
              shadowColor: Colors.blueAccent.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            product,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: status == 'Đã duyệt'
                                ? Colors.green[300]
                                : (status == 'Đang xử lý' ? Colors.orange[300] : Colors.grey[400]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, thickness: 1),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blueAccent),
                        const SizedBox(width: 6),
                        Expanded(child: Text('Người trả: $name')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.green),
                        const SizedBox(width: 6),
                        Text('SĐT: $phone'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.redAccent),
                        const SizedBox(width: 6),
                        Expanded(child: Text('Địa chỉ: $address')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 6),
                        Expanded(child: Text('Lý do trả: $reason')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('Thời gian: $formattedDate'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
