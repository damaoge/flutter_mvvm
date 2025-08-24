import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'permission_result.dart';
import 'permission_checker.dart';

/// 权限请求服务
/// 专门负责权限的请求和处理
class PermissionRequester {
  static final PermissionRequester _instance = PermissionRequester._internal();
  static PermissionRequester get instance => _instance;
  
  final PermissionChecker _checker = PermissionChecker.instance;
  
  PermissionRequester._internal();
  
  /// 请求单个权限
  Future<PermissionResult> requestPermission(Permission permission) async {
    try {
      LoggerUtil.i('请求权限: ${permission.toString()}');
      
      final status = await permission.request();
      final result = _mapPermissionStatus(status, permission);
      
      LoggerUtil.i('权限请求结果: ${permission.toString()} -> ${result.status}');
      return result;
    } catch (e) {
      LoggerUtil.e('请求权限失败: ${permission.toString()}, error: $e');
      return PermissionResult(
        permission: permission,
        status: PermissionResultStatus.error,
        message: e.toString(),
      );
    }
  }
  
  /// 请求多个权限
  Future<Map<Permission, PermissionResult>> requestPermissions(
    List<Permission> permissions,
  ) async {
    try {
      LoggerUtil.i('请求多个权限: ${permissions.map((p) => p.toString()).join(', ')}');
      
      final statusMap = await permissions.request();
      final resultMap = <Permission, PermissionResult>{};
      
      statusMap.forEach((permission, status) {
        resultMap[permission] = _mapPermissionStatus(status, permission);
      });
      
      LoggerUtil.i('多个权限请求完成');
      return resultMap;
    } catch (e) {
      LoggerUtil.e('请求多个权限失败: $e');
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
  
  /// 智能请求权限（先检查再请求）
  Future<PermissionResult> smartRequestPermission(Permission permission) async {
    // 先检查权限状态
    final checkResult = await _checker.checkPermission(permission);
    
    // 如果已经授予，直接返回
    if (checkResult.isGranted) {
      LoggerUtil.i('权限已授予，无需请求: ${permission.toString()}');
      return checkResult;
    }
    
    // 如果被永久拒绝，不再请求
    if (checkResult.isPermanentlyDenied) {
      LoggerUtil.w('权限被永久拒绝，无法请求: ${permission.toString()}');
      return checkResult;
    }
    
    // 请求权限
    return await requestPermission(permission);
  }
  
  /// 智能请求多个权限
  Future<Map<Permission, PermissionResult>> smartRequestPermissions(
    List<Permission> permissions,
  ) async {
    final resultMap = <Permission, PermissionResult>{};
    final needRequestPermissions = <Permission>[];
    
    // 先检查所有权限状态
    for (final permission in permissions) {
      final checkResult = await _checker.checkPermission(permission);
      
      if (checkResult.isGranted) {
        // 已授予，直接添加到结果
        resultMap[permission] = checkResult;
      } else if (checkResult.isPermanentlyDenied) {
        // 被永久拒绝，不请求
        resultMap[permission] = checkResult;
      } else {
        // 需要请求
        needRequestPermissions.add(permission);
      }
    }
    
    // 批量请求需要请求的权限
    if (needRequestPermissions.isNotEmpty) {
      final requestResults = await requestPermissions(needRequestPermissions);
      resultMap.addAll(requestResults);
    }
    
    return resultMap;
  }
  
  /// 请求相机权限
  Future<PermissionResult> requestCameraPermission() async {
    return await smartRequestPermission(Permission.camera);
  }
  
  /// 请求麦克风权限
  Future<PermissionResult> requestMicrophonePermission() async {
    return await smartRequestPermission(Permission.microphone);
  }
  
  /// 请求存储权限
  Future<PermissionResult> requestStoragePermission() async {
    return await smartRequestPermission(Permission.storage);
  }
  
  /// 请求照片权限
  Future<PermissionResult> requestPhotosPermission() async {
    return await smartRequestPermission(Permission.photos);
  }
  
  /// 请求位置权限
  Future<PermissionResult> requestLocationPermission() async {
    return await smartRequestPermission(Permission.location);
  }
  
  /// 请求始终位置权限
  Future<PermissionResult> requestLocationAlwaysPermission() async {
    return await smartRequestPermission(Permission.locationAlways);
  }
  
  /// 请求使用时位置权限
  Future<PermissionResult> requestLocationWhenInUsePermission() async {
    return await smartRequestPermission(Permission.locationWhenInUse);
  }
  
  /// 请求通知权限
  Future<PermissionResult> requestNotificationPermission() async {
    return await smartRequestPermission(Permission.notification);
  }
  
  /// 请求联系人权限
  Future<PermissionResult> requestContactsPermission() async {
    return await smartRequestPermission(Permission.contacts);
  }
  
  /// 请求日历权限
  Future<PermissionResult> requestCalendarPermission() async {
    return await smartRequestPermission(Permission.calendar);
  }
  
  /// 请求蓝牙权限
  Future<PermissionResult> requestBluetoothPermission() async {
    return await smartRequestPermission(Permission.bluetooth);
  }
  
  /// 请求蓝牙扫描权限
  Future<PermissionResult> requestBluetoothScanPermission() async {
    return await smartRequestPermission(Permission.bluetoothScan);
  }
  
  /// 请求蓝牙广播权限
  Future<PermissionResult> requestBluetoothAdvertisePermission() async {
    return await smartRequestPermission(Permission.bluetoothAdvertise);
  }
  
  /// 请求蓝牙连接权限
  Future<PermissionResult> requestBluetoothConnectPermission() async {
    return await smartRequestPermission(Permission.bluetoothConnect);
  }
  
  /// 请求常用权限组合
  Future<Map<Permission, PermissionResult>> requestCommonPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.photos,
      Permission.notification,
    ];
    
    return await smartRequestPermissions(permissions);
  }
  
  /// 请求媒体权限组合
  Future<Map<Permission, PermissionResult>> requestMediaPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.photos,
      Permission.storage,
    ];
    
    return await smartRequestPermissions(permissions);
  }
  
  /// 请求位置权限组合
  Future<Map<Permission, PermissionResult>> requestLocationPermissions() async {
    final permissions = [
      Permission.location,
      Permission.locationWhenInUse,
    ];
    
    return await smartRequestPermissions(permissions);
  }
  
  /// 打开应用设置页面
  Future<bool> openAppSettings() async {
    try {
      LoggerUtil.i('打开应用设置页面');
      return await openAppSettings();
    } catch (e) {
      LoggerUtil.e('打开应用设置页面失败: $e');
      return false;
    }
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