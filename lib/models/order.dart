import 'package:cloud_firestore/cloud_firestore.dart';

class MyOrder {
  final String id;
  final List<Map<String, dynamic>> items;
  final int total;
  final DateTime createdAt;

  MyOrder({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt,
  });

  factory MyOrder.fromMap(String id, Map<String, dynamic> data) {
    return MyOrder(
      id: id,
      items: List<Map<String, dynamic>>.from(data['items']),
      total: data['total'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
