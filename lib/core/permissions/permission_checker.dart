import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'permission_result.dart';

/// 权限检查服务
/// 专门负责权限状态的检查和验证
class PermissionChecker {
  static final PermissionChecker _instance = PermissionChecker._internal();
  static PermissionChecker get instance => _instance;
  
  PermissionChecker._internal();
  
  /// 检查权限状态
  Future<PermissionResult> checkPermission(Permission permission) async {
    try {
      final status = await permission.status;
      final result = _mapPermissionStatus(status, permission);
      
      LoggerUtil.d('检查权限状态: ${permission.toString()} -> ${result.status}');
      return result;
    } catch (e) {
      LoggerUtil.e('检查权限状态失败: ${permission.toString()}, error: $e');
      return PermissionResult(
        permission: permission,
        status: PermissionResultStatus.error,
        message: e.toString(),
      );
    }
  }
  
  /// 检查多个权限状态
  Future<Map<Permission, PermissionResult>> checkPermissions(
    List<Permission> permissions,
  ) async {
    try {
      final resultMap = <Permission, PermissionResult>{};
      
      for (final permission in permissions) {
        final result = await checkPermission(permission);
        resultMap[permission] = result;
      }
      
      return resultMap;
    } catch (e) {
      LoggerUtil.e('检查多个权限状态失败: $e');
      final resultMap = <Permission, PermissionResult>{};
      for (final permission in permissions) {
        resultMap[permission] = PermissionResult(
          permission: permission,
          status: PermissionResultStatus.error,
          message: e.toString(),
        );
      }
      return resultMap;
    }
  }
  
  /// 检查权限是否被永久拒绝
  Future<bool> isPermanentlyDenied(Permission permission) async {
    try {
      return await permission.isPermanentlyDenied;
    } catch (e) {
      LoggerUtil.e('检查权限是否被永久拒绝失败: ${permission.toString()}, error: $e');
      return false;
    }
  }
  
  /// 检查权限是否已授予
  Future<bool> isGranted(Permission permission) async {
    final result = await checkPermission(permission);
    return result.isGranted;
  }
  
  /// 检查权限是否被拒绝
  Future<bool> isDenied(Permission permission) async {
    final result = await checkPermission(permission);
    return result.isDenied;
  }
  
  /// 检查权限是否受限
  Future<bool> isRestricted(Permission permission) async {
    final result = await checkPermission(permission);
    return result.isRestricted;
  }
  
  /// 检查是否所有权限都已授予
  Future<bool> areAllGranted(List<Permission> permissions) async {
    final results = await checkPermissions(permissions);
    return results.values.every((result) => result.isGranted);
  }
  
  /// 检查是否有任何权限被永久拒绝
  Future<bool> hasAnyPermanentlyDenied(List<Permission> permissions) async {
    for (final permission in permissions) {
      if (await isPermanentlyDenied(permission)) {
        return true;
      }
    }
    return false;
  }
  
  /// 获取被拒绝的权限列表
  Future<List<Permission>> getDeniedPermissions(List<Permission> permissions) async {
    final results = await checkPermissions(permissions);
    return results.entries
        .where((entry) => entry.value.isDenied)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// 获取被永久拒绝的权限列表
  Future<List<Permission>> getPermanentlyDeniedPermissions(List<Permission> permissions) async {
    final results = await checkPermissions(permissions);
    return results.entries
        .where((entry) => entry.value.isPermanentlyDenied)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// 获取已授予的权限列表
  Future<List<Permission>> getGrantedPermissions(List<Permission> permissions) async {
    final results = await checkPermissions(permissions);
    return results.entries
        .where((entry) => entry.value.isGranted)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// 映射权限状态
  PermissionResult _mapPermissionStatus(PermissionStatus status, Permission permission) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionResult(
          permission: permission,
          status: PermissionResultStatus.granted,
          message: '权限已授予',
        );
      case PermissionStatus.denied:
        return PermissionResult(
          permission: permission,
          status: PermissionResultStatus.denied,
          message: '权限被拒绝',
        );
      case PermissionStatus.restricted:
        return PermissionResult(
          permission: permission,
          status: PermissionResultStatus.restricted,
          message: '权限受限',
        );
      case PermissionStatus.limited:
        return PermissionResult(
          permission: permission,
          status: PermissionResultStatus.limited,
          message: '权限受限（部分授予）',
        );
      case PermissionStatus.permanentlyDenied:
        return PermissionResult(
          permission: permission,
          status: PermissionResultStatus.permanentlyDenied,
          message: '权限被永久拒绝',
        );
      case PermissionStatus.provisional:
        return PermissionResult(
          permission: permission,
          status: PermissionResultStatus.provisional,
          message: '临时权限',
        );
    }
  }
}