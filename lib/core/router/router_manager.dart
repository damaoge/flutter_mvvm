import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'app_routes.dart';
import 'route_middleware.dart';
import 'navigation_service.dart';
import 'dialog_service.dart';

/// 路由管理器
/// 统一的路由管理入口，整合各个路由服务
class RouterManager {
  static final RouterManager _instance = RouterManager._internal();
  static RouterManager get instance => _instance;
  
  RouterManager._internal();
  
  // 服务实例
  NavigationService get navigation => NavigationService.instance;
  DialogService get dialog => DialogService.instance;
  
  /// 初始化路由管理器
  void init() {
    LoggerUtil.i('路由管理器初始化完成');
  }
  
  // 便捷方法 - 代理到NavigationService
  
  /// 跳转到指定页面
  Future<T?> push<T extends Object?>(
    String routeName, {
    dynamic arguments,
    bool preventDuplicates = true,
  }) => navigation.push<T>(routeName, arguments: arguments, preventDuplicates: preventDuplicates);
  
  /// 替换当前页面
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    String routeName, {
    dynamic arguments,
    TO? result,
  }) => navigation.pushReplacement<T, TO>(routeName, arguments: arguments, result: result);
  
  /// 清空栈并跳转到指定页面
  Future<T?> pushAndClearStack<T extends Object?>(
    String routeName, {
    dynamic arguments,
  }) => navigation.pushAndClearStack<T>(routeName, arguments: arguments);
  
  /// 返回上一页
  void pop<T extends Object?>([T? result]) => navigation.pop<T>(result);
  
  /// 返回到指定页面
  void popUntil(String routeName) => navigation.popUntil(routeName);
  
  /// 返回到根页面
  void popToRoot() => navigation.popToRoot();
  
  /// 检查是否可以返回
  bool canPop() => navigation.canPop();
  
  /// 获取当前路由名称
  String get currentRoute => navigation.currentRoute;
  
  /// 获取路由参数
  dynamic get arguments => navigation.arguments;
  
  /// 获取路由参数（泛型）
  T? getArguments<T>() => navigation.getArguments<T>();
  
  // 便捷方法 - 代理到DialogService
  
  /// 显示底部弹窗
  Future<T?> showBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) => dialog.showBottomSheet<T>(
    child: child,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: shape,
  );
  
  /// 显示对话框
  Future<T?> showDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
  }) => dialog.showDialog<T>(
    child: child,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
  );
  
  /// 显示Snackbar
  void showSnackbar({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Color? backgroundColor,
    Color? colorText,
    Widget? icon,
    bool isDismissible = true,
    DismissDirection? dismissDirection,
    VoidCallback? onTap,
  }) => dialog.showSnackbar(
    message: message,
    title: title,
    duration: duration,
    snackPosition: snackPosition,
    backgroundColor: backgroundColor,
    colorText: colorText,
    icon: icon,
    isDismissible: isDismissible,
    dismissDirection: dismissDirection,
    onTap: onTap,
  );
  
  /// 关闭所有对话框
  void closeAllDialogs() => dialog.closeAllDialogs();
  
  /// 关闭所有底部弹窗
  void closeAllBottomSheets() => dialog.closeAllBottomSheets();
  
  /// 关闭所有Snackbar
  void closeAllSnackbars() => dialog.closeAllSnackbars();
  
  /// 获取路由历史
  List<String> get routeHistory => navigation.routeHistory;
  
  /// 获取路由配置
  static List<GetPage> get pages => AppRoutes.pages;
  
  /// 获取未知路由配置
  static GetPage get unknownRoute => AppRoutes.unknownRoute;
  
  /// 获取初始路由
  static String get initialRoute => AppRoutes.initial;
}