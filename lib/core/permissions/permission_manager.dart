import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger_util.dart';

/// 权限管理器
/// 提供Android和iOS的统一权限管理接口
class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  static PermissionManager get instance => _instance;
  
  PermissionManager._internal();
  
  /// 初始化权限管理器
  Future<void> init() async {
    try {
      LoggerUtil.i('权限管理器初始化完成');
    } catch (e) {
      LoggerUtil.e('权限管理器初始化失败: $e');
    }
  }
  
  /// 请求单个权限
  Future<PermissionResult> requestPermission(Permission permission) async {
    try {
      LoggerUtil.i('请求权限: ${permission.toString()}');
      
      final status = await permission.request();
      final result = _mapPermissionStatus(status);
      
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
        resultMap[permission] = _mapPermissionStatus(status);
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
  
  /// 检查权限状态
  Future<PermissionResult> checkPermission(Permission permission) async {
    try {
      final status = await permission.status;
      final result = _mapPermissionStatus(status);
      
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
  
  /// 检查权限是否被永久拒绝
  Future<bool> isPermanentlyDenied(Permission permission) async {
    try {
      return await permission.isPermanentlyDenied;
    } catch (e) {
      LoggerUtil.e('检查权限是否被永久拒绝失败: ${permission.toString()}, error: $e');
      return false;
    }
  }
  
  /// 请求相机权限
  Future<PermissionResult> requestCameraPermission() async {
    return await requestPermission(Permission.camera);
  }
  
  /// 请求麦克风权限
  Future<PermissionResult> requestMicrophonePermission() async {
    return await requestPermission(Permission.microphone);
  }
  
  /// 请求存储权限
  Future<PermissionResult> requestStoragePermission() async {
    return await requestPermission(Permission.storage);
  }
  
  /// 请求照片权限
  Future<PermissionResult> requestPhotosPermission() async {
    return await requestPermission(Permission.photos);
  }
  
  /// 请求位置权限
  Future<PermissionResult> requestLocationPermission() async {
    return await requestPermission(Permission.location);
  }
  
  /// 请求始终位置权限
  Future<PermissionResult> requestLocationAlwaysPermission() async {
    return await requestPermission(Permission.locationAlways);
  }
  
  /// 请求使用时位置权限
  Future<PermissionResult> requestLocationWhenInUsePermission() async {
    return await requestPermission(Permission.locationWhenInUse);
  }
  
  /// 请求通知权限
  Future<PermissionResult> requestNotificationPermission() async {
    return await requestPermission(Permission.notification);
  }
  
  /// 请求联系人权限
  Future<PermissionResult> requestContactsPermission() async {
    return await requestPermission(Permission.contacts);
  }
  
  /// 请求日历权限
  Future<PermissionResult> requestCalendarPermission() async {
    return await requestPermission(Permission.calendar);
  }
  
  /// 请求蓝牙权限
  Future<PermissionResult> requestBluetoothPermission() async {
    return await requestPermission(Permission.bluetooth);
  }
  
  /// 请求蓝牙扫描权限
  Future<PermissionResult> requestBluetoothScanPermission() async {
    return await requestPermission(Permission.bluetoothScan);
  }
  
  /// 请求蓝牙广播权限
  Future<PermissionResult> requestBluetoothAdvertisePermission() async {
    return await requestPermission(Permission.bluetoothAdvertise);
  }
  
  /// 请求蓝牙连接权限
  Future<PermissionResult> requestBluetoothConnectPermission() async {
    return await requestPermission(Permission.bluetoothConnect);
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
    
    return await requestPermissions(permissions);
  }
  
  /// 请求媒体权限组合
  Future<Map<Permission, PermissionResult>> requestMediaPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.photos,
      Permission.storage,
    ];
    
    return await requestPermissions(permissions);
  }
  
  /// 请求位置权限组合
  Future<Map<Permission, PermissionResult>> requestLocationPermissions() async {
    final permissions = [
      Permission.location,
      Permission.locationWhenInUse,
    ];
    
    return await requestPermissions(permissions);
  }
  
  /// 映射权限状态
  PermissionResult _mapPermissionStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionResult(
          permission: null,
          status: PermissionResultStatus.granted,
          message: '权限已授予',
        );
      case PermissionStatus.denied:
        return PermissionResult(
          permission: null,
          status: PermissionResultStatus.denied,
          message: '权限被拒绝',
        );
      case PermissionStatus.restricted:
        return PermissionResult(
          permission: null,
          status: PermissionResultStatus.restricted,
          message: '权限受限',
        );
      case PermissionStatus.limited:
        return PermissionResult(
          permission: null,
          status: PermissionResultStatus.limited,
          message: '权限受限（部分授予）',
        );
      case PermissionStatus.permanentlyDenied:
        return PermissionResult(
          permission: null,
          status: PermissionResultStatus.permanentlyDenied,
          message: '权限被永久拒绝',
        );
      case PermissionStatus.provisional:
        return PermissionResult(
          permission: null,
          status: PermissionResultStatus.provisional,
          message: '临时权限',
        );
    }
  }
}

/// 权限请求结果
class PermissionResult {
  final Permission? permission;
  final PermissionResultStatus status;
  final String message;
  
  PermissionResult({
    required this.permission,
    required this.status,
    required this.message,
  });
  
  /// 是否已授予权限
  bool get isGranted => status == PermissionResultStatus.granted;
  
  /// 是否被拒绝
  bool get isDenied => status == PermissionResultStatus.denied;
  
  /// 是否被永久拒绝
  bool get isPermanentlyDenied => status == PermissionResultStatus.permanentlyDenied;
  
  /// 是否受限
  bool get isRestricted => status == PermissionResultStatus.restricted;
  
  /// 是否为临时权限
  bool get isProvisional => status == PermissionResultStatus.provisional;
  
  /// 是否为有限权限
  bool get isLimited => status == PermissionResultStatus.limited;
  
  /// 是否发生错误
  bool get hasError => status == PermissionResultStatus.error;
  
  @override
  String toString() {
    return 'PermissionResult{permission: $permission, status: $status, message: $message}';
  }
}

/// 权限结果状态
enum PermissionResultStatus {
  /// 已授予
  granted,
  
  /// 被拒绝
  denied,
  
  /// 受限
  restricted,
  
  /// 有限权限（iOS）
  limited,
  
  /// 永久拒绝
  permanentlyDenied,
  
  /// 临时权限（iOS）
  provisional,
  
  /// 错误
  error,
}

/// 沉浸式状态栏管理器
class ImmersiveManager {
  static final ImmersiveManager _instance = ImmersiveManager._internal();
  static ImmersiveManager get instance => _instance;
  
  ImmersiveManager._internal();
  
  /// 设置沉浸式状态栏
  static void setImmersiveStatusBar({
    Color? statusBarColor,
    Brightness? statusBarBrightness,
    Color? navigationBarColor,
    Brightness? navigationBarIconBrightness,
  }) {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: statusBarColor ?? Colors.transparent,
          statusBarBrightness: statusBarBrightness ?? Brightness.light,
          statusBarIconBrightness: statusBarBrightness == Brightness.light 
              ? Brightness.dark 
              : Brightness.light,
          navigationBarColor: navigationBarColor ?? Colors.white,
          navigationBarIconBrightness: navigationBarIconBrightness ?? Brightness.dark,
        ),
      );
      
      LoggerUtil.i('设置沉浸式状态栏完成');
    } catch (e) {
      LoggerUtil.e('设置沉浸式状态栏失败: $e');
    }
  }
  
  /// 设置浅色状态栏
  static void setLightStatusBar() {
    setImmersiveStatusBar(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      navigationBarColor: Colors.white,
      navigationBarIconBrightness: Brightness.dark,
    );
  }
  
  /// 设置深色状态栏
  static void setDarkStatusBar() {
    setImmersiveStatusBar(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      navigationBarColor: Colors.black,
      navigationBarIconBrightness: Brightness.light,
    );
  }
  
  /// 隐藏状态栏
  static void hideStatusBar() {
    try {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom],
      );
      LoggerUtil.i('隐藏状态栏完成');
    } catch (e) {
      LoggerUtil.e('隐藏状态栏失败: $e');
    }
  }
  
  /// 显示状态栏
  static void showStatusBar() {
    try {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      LoggerUtil.i('显示状态栏完成');
    } catch (e) {
      LoggerUtil.e('显示状态栏失败: $e');
    }
  }
  
  /// 全屏模式
  static void setFullScreen() {
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      LoggerUtil.i('设置全屏模式完成');
    } catch (e) {
      LoggerUtil.e('设置全屏模式失败: $e');
    }
  }
  
  /// 退出全屏模式
  static void exitFullScreen() {
    try {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      LoggerUtil.i('退出全屏模式完成');
    } catch (e) {
      LoggerUtil.e('退出全屏模式失败: $e');
    }
  }
}