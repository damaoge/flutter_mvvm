import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'package:flutter_mvvm/core/storage/storage_manager.dart';
import 'app_routes.dart';

/// 路由中间件
/// 处理路由拦截、权限验证等逻辑
class RouteMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;
  
  @override
  RouteSettings? redirect(String? route) {
    LoggerUtil.d('路由中间件检查: $route');
    
    // 检查是否需要登录
    if (_requiresAuth(route)) {
      if (!_isLoggedIn()) {
        LoggerUtil.w('未登录，重定向到登录页面');
        return const RouteSettings(name: AppRoutes.login);
      }
    }
    
    // 检查是否已登录但访问登录页面
    if (_isAuthPage(route) && _isLoggedIn()) {
      LoggerUtil.i('已登录，重定向到首页');
      return const RouteSettings(name: AppRoutes.home);
    }
    
    return null;
  }
  
  @override
  GetPage? onPageCalled(GetPage? page) {
    LoggerUtil.route('PAGE_CALLED', page?.name ?? 'unknown');
    return super.onPageCalled(page);
  }
  
  @override
  Widget onPageBuilt(Widget page) {
    LoggerUtil.route('PAGE_BUILT', Get.currentRoute);
    return super.onPageBuilt(page);
  }
  
  @override
  void onPageDispose() {
    LoggerUtil.route('PAGE_DISPOSE', Get.currentRoute);
    super.onPageDispose();
  }
  
  /// 检查路由是否需要认证
  bool _requiresAuth(String? route) {
    if (route == null) return false;
    
    const authRequiredRoutes = [
      AppRoutes.home,
      AppRoutes.profile,
      AppRoutes.settings,
    ];
    
    return authRequiredRoutes.contains(route);
  }
  
  /// 检查是否为认证相关页面
  bool _isAuthPage(String? route) {
    if (route == null) return false;
    
    const authPages = [
      AppRoutes.login,
      AppRoutes.register,
    ];
    
    return authPages.contains(route);
  }
  
  /// 检查用户是否已登录
  bool _isLoggedIn() {
    final token = StorageManager.instance.getString('user_token');
    return token != null && token.isNotEmpty;
  }
}

/// 登录验证中间件
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;
  
  @override
  RouteSettings? redirect(String? route) {
    if (!_isLoggedIn()) {
      LoggerUtil.w('AuthMiddleware: 用户未登录，重定向到登录页');
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
  
  bool _isLoggedIn() {
    final token = StorageManager.instance.getString('user_token');
    return token != null && token.isNotEmpty;
  }
}

/// 权限验证中间件
class PermissionMiddleware extends GetMiddleware {
  final List<String> requiredPermissions;
  
  PermissionMiddleware({required this.requiredPermissions});
  
  @override
  int? get priority => 3;
  
  @override
  RouteSettings? redirect(String? route) {
    // 这里可以添加权限检查逻辑
    // 例如检查用户角色、权限等
    LoggerUtil.d('PermissionMiddleware: 检查权限 $requiredPermissions');
    return null;
  }
}

/// 网络状态中间件
class NetworkMiddleware extends GetMiddleware {
  @override
  int? get priority => 4;
  
  @override
  RouteSettings? redirect(String? route) {
    // 这里可以添加网络状态检查
    // 如果需要网络但当前无网络，可以重定向到离线页面
    return null;
  }
}