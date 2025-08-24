import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/logger_util.dart';
import '../../pages/splash/splash_page.dart';
import '../../pages/login/login_page.dart';
import '../../pages/register/register_page.dart';
import '../../pages/home/home_page.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/settings/settings_page.dart';
import '../../pages/about/about_page.dart';

/// 路由管理器
/// 提供统一的页面导航和路由管理功能
class RouterManager {
  static final RouterManager _instance = RouterManager._internal();
  static RouterManager get instance => _instance;
  
  RouterManager._internal();
  
  /// 初始化路由管理器
  void init() {
    LoggerUtil.i('路由管理器初始化完成');
  }
  
  /// 跳转到指定页面
  Future<T?> push<T extends Object?>(
    String routeName, {
    dynamic arguments,
    bool preventDuplicates = true,
  }) async {
    try {
      LoggerUtil.route('PUSH', routeName, arguments: arguments);
      
      return await Get.toNamed<T>(
        routeName,
        arguments: arguments,
        preventDuplicates: preventDuplicates,
      );
    } catch (e) {
      LoggerUtil.e('页面跳转失败: $routeName, error: $e');
      return null;
    }
  }
  
  /// 替换当前页面
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    String routeName, {
    dynamic arguments,
    TO? result,
  }) async {
    try {
      LoggerUtil.route('PUSH_REPLACEMENT', routeName, arguments: arguments);
      
      return await Get.offNamed<T>(
        routeName,
        arguments: arguments,
        result: result,
      );
    } catch (e) {
      LoggerUtil.e('页面替换失败: $routeName, error: $e');
      return null;
    }
  }
  
  /// 清空栈并跳转到指定页面
  Future<T?> pushAndClearStack<T extends Object?>(
    String routeName, {
    dynamic arguments,
  }) async {
    try {
      LoggerUtil.route('PUSH_AND_CLEAR_STACK', routeName, arguments: arguments);
      
      return await Get.offAllNamed<T>(
        routeName,
        arguments: arguments,
      );
    } catch (e) {
      LoggerUtil.e('清空栈跳转失败: $routeName, error: $e');
      return null;
    }
  }
  
  /// 返回上一页
  void pop<T extends Object?>([T? result]) {
    try {
      if (canPop()) {
        LoggerUtil.route('POP', Get.currentRoute, arguments: result);
        Get.back<T>(result: result);
      } else {
        LoggerUtil.w('无法返回，当前已是根页面');
      }
    } catch (e) {
      LoggerUtil.e('页面返回失败: $e');
    }
  }
  
  /// 返回到指定页面
  void popUntil(String routeName) {
    try {
      LoggerUtil.route('POP_UNTIL', routeName);
      Get.until((route) => route.settings.name == routeName);
    } catch (e) {
      LoggerUtil.e('返回到指定页面失败: $routeName, error: $e');
    }
  }
  
  /// 返回到根页面
  void popToRoot() {
    try {
      LoggerUtil.route('POP_TO_ROOT', 'ROOT');
      Get.until((route) => route.isFirst);
    } catch (e) {
      LoggerUtil.e('返回到根页面失败: $e');
    }
  }
  
  /// 检查是否可以返回
  bool canPop() {
    return Get.key.currentState?.canPop() ?? false;
  }
  
  /// 获取当前路由名称
  String get currentRoute {
    return Get.currentRoute;
  }
  
  /// 获取路由参数
  dynamic get arguments {
    return Get.arguments;
  }
  
  /// 获取路由参数（泛型）
  T? getArguments<T>() {
    try {
      return Get.arguments as T?;
    } catch (e) {
      LoggerUtil.w('获取路由参数失败: $e');
      return null;
    }
  }
  
  /// 显示底部弹窗
  Future<T?> showBottomSheet<T>(
    Widget bottomSheet, {
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) async {
    try {
      LoggerUtil.route('SHOW_BOTTOM_SHEET', 'BottomSheet');
      
      return await Get.bottomSheet<T>(
        bottomSheet,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
      );
    } catch (e) {
      LoggerUtil.e('显示底部弹窗失败: $e');
      return null;
    }
  }
  
  /// 显示对话框
  Future<T?> showDialog<T>(
    Widget dialog, {
    bool barrierDismissible = true,
    Color? barrierColor,
  }) async {
    try {
      LoggerUtil.route('SHOW_DIALOG', 'Dialog');
      
      return await Get.dialog<T>(
        dialog,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
      );
    } catch (e) {
      LoggerUtil.e('显示对话框失败: $e');
      return null;
    }
  }
  
  /// 显示Snackbar
  void showSnackbar(
    String title,
    String message, {
    Duration? duration,
    SnackPosition? snackPosition,
    Color? backgroundColor,
    Color? colorText,
    Widget? icon,
    bool? isDismissible,
    DismissDirection? dismissDirection,
  }) {
    try {
      LoggerUtil.route('SHOW_SNACKBAR', title);
      
      Get.snackbar(
        title,
        message,
        duration: duration ?? const Duration(seconds: 3),
        snackPosition: snackPosition ?? SnackPosition.TOP,
        backgroundColor: backgroundColor,
        colorText: colorText,
        icon: icon,
        isDismissible: isDismissible ?? true,
        dismissDirection: dismissDirection ?? DismissDirection.horizontal,
      );
    } catch (e) {
      LoggerUtil.e('显示Snackbar失败: $e');
    }
  }
  
  /// 关闭所有弹窗
  void closeAllDialogs() {
    try {
      if (Get.isDialogOpen ?? false) {
        Get.until((route) => !Get.isDialogOpen!);
        LoggerUtil.route('CLOSE_ALL_DIALOGS', 'ALL');
      }
    } catch (e) {
      LoggerUtil.e('关闭所有弹窗失败: $e');
    }
  }
  
  /// 关闭所有底部弹窗
  void closeAllBottomSheets() {
    try {
      if (Get.isBottomSheetOpen ?? false) {
        Get.until((route) => !Get.isBottomSheetOpen!);
        LoggerUtil.route('CLOSE_ALL_BOTTOM_SHEETS', 'ALL');
      }
    } catch (e) {
      LoggerUtil.e('关闭所有底部弹窗失败: $e');
    }
  }
  
  /// 关闭所有Snackbar
  void closeAllSnackbars() {
    try {
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
        LoggerUtil.route('CLOSE_ALL_SNACKBARS', 'ALL');
      }
    } catch (e) {
      LoggerUtil.e('关闭所有Snackbar失败: $e');
    }
  }
  
  /// 获取路由历史
  List<String> getRouteHistory() {
    // Get包没有直接提供路由历史，这里返回当前路由
    return [Get.currentRoute];
  }
  
  /// 检查路由是否存在
  bool routeExists(String routeName) {
    try {
      // 这里可以根据实际的路由配置来检查
      return AppRoutes.routes.containsKey(routeName);
    } catch (e) {
      LoggerUtil.e('检查路由是否存在失败: $routeName, error: $e');
      return false;
    }
  }
}

/// 应用路由配置
class AppRoutes {
  // 路由名称常量
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';
  
  // 路由页面映射
  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => const LoginPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: profile,
      page: () => const ProfilePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: about,
      page: () => const AboutPage(),
      transition: Transition.rightToLeft,
    ),
  ];
  
  // 路由映射
  static final Map<String, GetPage> routes = {
    for (var page in pages) page.name: page,
  };
  
  /// 获取所有路由页面
  static List<GetPage> get pages => routes.values.toList();
  
  /// 初始路由
  static String get initialRoute => splash;
}

/// 路由中间件
class RouteMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    LoggerUtil.route('MIDDLEWARE_REDIRECT', route ?? 'UNKNOWN');
    
    // 这里可以添加路由拦截逻辑
    // 例如：检查用户登录状态，权限验证等
    
    return null; // 返回null表示不重定向
  }
  
  @override
  GetPage? onPageCalled(GetPage? page) {
    LoggerUtil.route('MIDDLEWARE_PAGE_CALLED', page?.name ?? 'UNKNOWN');
    return super.onPageCalled(page);
  }
  
  @override
  Widget onPageBuilt(Widget page) {
    LoggerUtil.route('MIDDLEWARE_PAGE_BUILT', Get.currentRoute);
    return super.onPageBuilt(page);
  }
}

// 占位页面类（实际项目中需要创建对应的页面）
class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Splash Page'),
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Login Page'),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Register Page'),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Profile Page'),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings Page'),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('About Page'),
      ),
    );
  }
}