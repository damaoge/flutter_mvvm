import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 导航服务
/// 专门处理页面导航逻辑
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  static NavigationService get instance => _instance;
  
  NavigationService._internal();
  
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
      LoggerUtil.route('POP_TO_ROOT', 'root');
      Get.offAllNamed(Get.rootDelegate.history.first.name!);
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
  
  /// 获取路由参数（类型安全）
  T? getArguments<T>() {
    try {
      return Get.arguments as T?;
    } catch (e) {
      LoggerUtil.w('获取路由参数失败: $e');
      return null;
    }
  }
  
  /// 获取路由参数中的指定字段
  T? getArgumentField<T>(String key) {
    try {
      final args = Get.arguments;
      if (args is Map<String, dynamic>) {
        return args[key] as T?;
      }
      return null;
    } catch (e) {
      LoggerUtil.w('获取路由参数字段失败: $key, error: $e');
      return null;
    }
  }
  
  /// 检查当前是否在指定路由
  bool isCurrentRoute(String routeName) {
    return Get.currentRoute == routeName;
  }
  
  /// 获取路由历史栈
  List<String> get routeHistory {
    return Get.rootDelegate.history
        .map((route) => route.name ?? 'unknown')
        .toList();
  }
  
  /// 清空路由历史（保留当前页面）
  void clearHistory() {
    try {
      final currentRoute = Get.currentRoute;
      Get.offAllNamed(currentRoute);
      LoggerUtil.route('CLEAR_HISTORY', currentRoute);
    } catch (e) {
      LoggerUtil.e('清空路由历史失败: $e');
    }
  }
}