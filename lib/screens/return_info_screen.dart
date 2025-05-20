import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReturnInfoScreen extends StatefulWidget {
  const ReturnInfoScreen({Key? key}) : super(key: key);

  @override
  State<ReturnInfoScreen> createState() => _ReturnInfoScreenState();
}

class _ReturnInfoScreenState extends State<ReturnInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController(); // Thêm lý do

  List<String> productTitles = [];
  String? selectedProduct;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadUserProfile(),
      _loadCartProducts(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _nameController.text = data['fullName'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
          _addressController.text = data['address'] ?? '';
        }
      }
    } catch (e) {
      print("Lỗi lấy thông tin user profile: $e");
    }
  }

  Future<void> _loadCartProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userEmail = user.email;
      if (userEmail == null) return;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('email', isEqualTo: userEmail)
          .get();

      List<String> allProductTitles = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data != null && data['items'] != null) {
          List items = data['items'];

          for (var item in items) {
            bool usedDiscount = false;
            if (item.containsKey('usedDiscount')) {
              usedDiscount = item['usedDiscount'] == true;
            }
            if (!usedDiscount) {
              allProductTitles.add(item['title']);
            }
          }
        }
      }

      final uniqueProductTitles = allProductTitles.toSet().toList();

      setState(() {
        productTitles = uniqueProductTitles;
        selectedProduct = productTitles.isNotEmpty ? productTitles[0] : null;
      });
    } catch (e) {
      print("Lỗi lấy sản phẩm trong đơn hàng: $e");
    }
  }

  Future<void> _submitReturnInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection("return_requests").add({
          "name": _nameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "product": selectedProduct ?? "",
          "address": _addressController.text.trim(),
          "reason": _reasonController.text.trim(), // Ghi lý do
          "timestamp": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thông tin đã được gửi đi")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi gửi thông tin: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _reasonController.dispose(); // dispose lý do
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin trả hàng"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Tên khách hàng",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) => value!.isEmpty ? "Nhập tên khách hàng" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Số điện thoại",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Nhập số điện thoại" : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Sản phẩm muốn trả",
                  prefixIcon: const Icon(Icons.shopping_cart),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                items: productTitles.map((title) {
                  return DropdownMenuItem<String>(
                    value: title,
                    child: Text(title),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProduct = value;
                  });
                },
                validator: (value) => (value == null || value.isEmpty) ? "Chọn sản phẩm muốn trả" : null,
                value: selectedProduct,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Địa chỉ",
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) => value!.isEmpty ? "Nhập địa chỉ" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: "Lý do trả hàng",
                  prefixIcon: const Icon(Icons.note_alt),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) => value!.isEmpty ? "Nhập lý do trả hàng" : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitReturnInfo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text(
                  "Gửi thông tin",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
