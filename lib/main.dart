import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/user_info_screen.dart';
import 'screens/edit_profile_screen.dart'; // ✅
import 'admin_screen/admin_home_screen.dart'; // ✅
import 'providers/order_provider.dart';
import 'screens/return_policy_screen.dart';       // ✅
import 'screens/return_info_screen.dart';
import 'screens/order_list_screen.dart';         // ✅
import 'providers/discount_provider.dart'; // ✅ Import DiscountProvider
import 'admin_screen/return_requests_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ⚡️ Khởi tạo Firebase

  final authProvider = AuthProvider();
  await authProvider.loadToken(); // Load token & dữ liệu người dùng trước khi chạy app

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => DiscountProvider()), // ✅ Thêm DiscountProvider
      ],
      child: MyApp(authProvider),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  MyApp(this.authProvider);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Store App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSans',
      ),
      home: _getInitialScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/cart': (context) => CartScreen(),
        '/checkout': (context) => CheckoutScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/user_info': (context) => UserInfoScreen(),
        '/admin': (context) => AdminHomeScreen(), // ✅ Admin
        '/edit_profile': (context) => EditProfileScreen(), // ✅ Edit Profile
        '/return_policy': (context) => ReturnPolicyScreen(), // ✅ Chính sách trả hàng
        '/return_info': (context) => ReturnInfoScreen(),     // ✅ Thông tin trả hàng
        '/orders': (context) => OrderListScreen(),
        '/return_requests': (context) => ReturnRequestsScreen(),

      },
    );
  }

  /// ✅ Xác định màn hình khởi động dựa vào trạng thái đăng nhập
  Widget _getInitialScreen() {
    if (authProvider.isAuthenticated) {
      if (authProvider.email == 'admin@gmail.com') {
        return AdminHomeScreen();
      } else if (authProvider.fullName.isNotEmpty) {
        return HomeScreen();
      } else {
        return UserInfoScreen();
      }
    } else {
      return LoginScreen();
    }
  }
}
