import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as my_auth;
import 'dart:math';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _acceptTerms = false;

  void _register() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bạn phải chấp nhận điều khoản và điều kiện!")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mật khẩu không khớp!")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final auth = Provider.of<my_auth.AuthProvider>(context, listen: false);

    String message = await auth.register(
      _emailController.text,
      _passwordController.text,
      context,
    );

    if (message == "Đăng ký thành công!") {
      FirebaseAuth.instance.authStateChanges().listen((user) async {
        if (user != null && mounted) {
          String uid = user.uid;
          String email = user.email ?? "";

          // 🔥 Tạo mã giảm giá và LƯU VÀO COLLECTION "discountCodes"
          List<Map<String, dynamic>> discountCodes = [];
          for (int i = 0; i < 10; i++) {  // Tạo 10 mã giảm giá
            discountCodes.add({
              'code': _generateRandomCode(),
              'amount': _generateRandomAmount(), // Sử dụng hàm tạo giá trị ngẫu nhiên
              'expiryDate': DateTime.now().add(Duration(days: 30)).toIso8601String(),
              'isUsed': false,
            });
          }

          await FirebaseFirestore.instance.collection('discountCodes').doc(uid).set({
            'email': email,
            'discountCodes': discountCodes,
          });

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        }
      });
    }

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _generateRandomCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    Random rnd = Random();
    String code = "";
    for (int i = 0; i < 8; i++) {
      code += chars[rnd.nextInt(chars.length)];
    }
    return code;
  }

  // Tạo giá trị ngẫu nhiên trong khoảng từ 10,000 đến 50,000
  int _generateRandomAmount() {
    Random rnd = Random();
    return 10000 + rnd.nextInt(40001); // Giá trị ngẫu nhiên trong khoảng 10k đến 50k
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Đăng ký tài khoản"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle("Email"),
            _buildTextField(_emailController, "Nhập email của bạn", TextInputType.emailAddress, false),
            _buildTitle("Mật khẩu"),
            _buildTextField(_passwordController, "Nhập mật khẩu", TextInputType.text, true),
            _buildTitle("Xác nhận mật khẩu"),
            _buildTextField(_confirmPasswordController, "Nhập lại mật khẩu", TextInputType.text, true),
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (value) => setState(() => _acceptTerms = value!),
                  activeColor: Colors.blueAccent,
                ),
                const Text("Tôi đồng ý với ", style: TextStyle(fontSize: 14)),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Điều khoản & Điều kiện",
                    style: TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _register,
                      child: const Text("Đăng ký", style: TextStyle(fontSize: 16)),
                    ),
                  ),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text("Đã có tài khoản? Đăng nhập", style: TextStyle(fontSize: 14, color: Colors.blueAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, TextInputType keyboardType, bool isPassword) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
