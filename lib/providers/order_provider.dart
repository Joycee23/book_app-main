import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/order.dart' as model; // đặt biệt danh để tránh trùng tên

class OrderProvider with ChangeNotifier {
  List<model.MyOrder> _orders = [];
  List<model.MyOrder> get orders => _orders;

  Future<void> fetchOrders(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    _orders = snapshot.docs
        .map((doc) => model.MyOrder.fromMap(doc.id, doc.data()))
        .toList();
    notifyListeners();
  }
}
