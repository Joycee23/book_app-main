import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_app/providers/auth_provider.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Nếu đã có thông tin người dùng, nạp dữ liệu vào controller
    if (authProvider.isAuthenticated) {
      _emailController.text = authProvider.email ?? '';
      _fullNameController.text = authProvider.fullName;
      _phoneController.text = authProvider.phoneNumber;
      _addressController.text = authProvider.address;
    }
  }

  void _saveUserInfo(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      Provider.of<AuthProvider>(context, listen: false).updateUserInfo(
        email: _emailController.text,
        fullName: _fullNameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
      );

      // Điều hướng về HomeScreen sau khi nhập thông tin
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🌟 Đổi nền sang trắng
      appBar: AppBar(
        title: const Text("Nhập thông tin cá nhân"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle("Email"),
              _buildTextField(_emailController, "Nhập email của bạn", TextInputType.emailAddress),
              _buildTitle("Họ và Tên"),
              _buildTextField(_fullNameController, "Nhập họ và tên", TextInputType.text),
              _buildTitle("Số điện thoại"),
              _buildTextField(_phoneController, "Nhập số điện thoại", TextInputType.phone),
              _buildTitle("Địa chỉ nhận hàng"),
              _buildTextField(_addressController, "Nhập địa chỉ nhận hàng", TextInputType.text),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _saveUserInfo(context),
                  child: const Text("Lưu thông tin", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Tiêu đề cho từng mục nhập
  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent),
      ),
    );
  }

  /// 🔹 Ô nhập liệu với thiết kế đẹp hơn
  Widget _buildTextField(TextEditingController controller, String hint, TextInputType keyboardType) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      validator: (value) => value!.isEmpty ? "Vui lòng nhập thông tin" : null,
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
