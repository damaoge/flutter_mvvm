import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_mvvm/core/base/base_view_model.dart';
import 'package:flutter_mvvm/core/permissions/permission_manager.dart';
import 'package:flutter_mvvm/core/permissions/permission_result.dart';

/// BaseViewModel权限管理扩展
/// 提供统一的权限请求和检查功能
extension BaseViewModelPermissionExtension on BaseViewModel {
  /// 请求单个权限
  Future<PermissionResult> requestPermission(Permission permission) async {
    return await PermissionManager.instance.requestPermission(permission);
  }

  /// 请求多个权限
  Future<Map<Permission, PermissionResult>> requestPermissions(
    List<Permission> permissions,
  ) async {
    return await PermissionManager.instance.requestPermissions(permissions);
  }

  /// 检查权限状态
  Future<PermissionStatus> checkPermission(Permission permission) async {
    return await PermissionManager.instance.checker.checkPermission(permission);
  }

  /// 检查多个权限状态
  Future<Map<Permission, PermissionStatus>> checkPermissions(
    List<Permission> permissions,
  ) async {
    return await PermissionManager.instance.checker.checkPermissions(permissions);
  }

  /// 打开应用设置页面
  Future<bool> openAppSettings() async {
    return await PermissionManager.instance.checker.openAppSettings();
  }
}