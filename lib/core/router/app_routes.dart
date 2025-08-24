import 'package:get/get.dart';
import 'package:flutter_mvvm/pages/splash/splash_page.dart';
import 'package:flutter_mvvm/pages/login/login_page.dart';
import 'package:flutter_mvvm/pages/register/register_page.dart';
import 'package:flutter_mvvm/pages/home/home_page.dart';
import 'package:flutter_mvvm/pages/profile/profile_page.dart';
import 'package:flutter_mvvm/pages/settings/settings_page.dart';
import 'package:flutter_mvvm/pages/about/about_page.dart';

/// 应用路由配置
/// 管理所有路由常量和页面映射
class AppRoutes {
  // 私有构造函数，防止实例化
  AppRoutes._();
  
  // 路由常量
  static const String initial = '/splash';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';
  
  /// 获取所有路由页面
  static List<GetPage> get pages => [
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: profile,
      page: () => const ProfilePage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: about,
      page: () => const AboutPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
  
  /// 获取未知路由页面
  static GetPage get unknownRoute => GetPage(
    name: '/notfound',
    page: () => const _NotFoundPage(),
    transition: Transition.fadeIn,
  );
}

/// 404页面
class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '页面未找到',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}