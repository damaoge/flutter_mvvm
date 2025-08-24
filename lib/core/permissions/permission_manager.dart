import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'permission_checker.dart';
import 'permission_requester.dart';
import 'permission_result.dart';
import 'ui_controller.dart';

/// 权限管理器
/// 提供Android和iOS的统一权限管理接口
class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  static PermissionManager get instance => _instance;
  
  final PermissionChecker _checker = PermissionChecker.instance;
  final PermissionRequester _requester = PermissionRequester.instance;
  final UIController _uiController = UIController.instance;
  
  PermissionManager._internal();
  
  /// 权限检查器
  PermissionChecker get checker => _checker;
  
  /// 权限请求器
  PermissionRequester get requester => _requester;
  
  /// UI控制器
  UIController get uiController => _uiController;
  
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
    return await _requester.requestPermission(permission);
  }
  
  /// 请求多个权限
  Future<Map<Permission, PermissionResult>> requestPermissions(
    List<Permission> permissions,
  ) async {
    return await _requester.requestPermissions(permissions);
  }
  
  /// 检查权限状态
  Future<PermissionResult> checkPermission(Permission permission) async {
    return await _checker.checkPermission(permission);
  }
  
  /// 检查多个权限状态
  Future<Map<Permission, PermissionResult>> checkPermissions(
    List<Permission> permissions,
  ) async {
    return await _checker.checkPermissions(permissions);
  }
  
  /// 打开应用设置页面
  Future<bool> openAppSettings() async {
    return await _requester.openAppSettings();
  }
  
  /// 检查权限是否被永久拒绝
  Future<bool> isPermanentlyDenied(Permission permission) async {
    return await _checker.isPermanentlyDenied(permission);
  }
  
  /// 请求相机权限
  Future<PermissionResult> requestCameraPermission() async {
    return await _requester.requestCameraPermission();
  }
  
  /// 请求麦克风权限
  Future<PermissionResult> requestMicrophonePermission() async {
    return await _requester.requestMicrophonePermission();
  }
  
  /// 请求存储权限
  Future<PermissionResult> requestStoragePermission() async {
    return await _requester.requestStoragePermission();
  }
  
  /// 请求照片权限
  Future<PermissionResult> requestPhotosPermission() async {
    return await _requester.requestPhotosPermission();
  }
  
  /// 请求位置权限
  Future<PermissionResult> requestLocationPermission() async {
    return await _requester.requestLocationPermission();
  }
  
  /// 请求始终位置权限
  Future<PermissionResult> requestLocationAlwaysPermission() async {
    return await _requester.requestLocationAlwaysPermission();
  }
  
  /// 请求使用时位置权限
  Future<PermissionResult> requestLocationWhenInUsePermission() async {
    return await _requester.requestLocationWhenInUsePermission();
  }
  
  /// 请求通知权限
  Future<PermissionResult> requestNotificationPermission() async {
    return await _requester.requestNotificationPermission();
  }
  
  /// 请求联系人权限
  Future<PermissionResult> requestContactsPermission() async {
    return await _requester.requestContactsPermission();
  }
  
  /// 请求日历权限
  Future<PermissionResult> requestCalendarPermission() async {
    return await _requester.requestCalendarPermission();
  }
  
  /// 请求蓝牙权限
  Future<PermissionResult> requestBluetoothPermission() async {
    return await _requester.requestBluetoothPermission();
  }
  
  /// 请求蓝牙扫描权限
  Future<PermissionResult> requestBluetoothScanPermission() async {
    return await _requester.requestBluetoothScanPermission();
  }
  
  /// 请求蓝牙广播权限
  Future<PermissionResult> requestBluetoothAdvertisePermission() async {
    return await _requester.requestBluetoothAdvertisePermission();
  }
  
  /// 请求蓝牙连接权限
  Future<PermissionResult> requestBluetoothConnectPermission() async {
    return await _requester.requestBluetoothConnectPermission();
  }
  
  /// 请求常用权限组合
  Future<Map<Permission, PermissionResult>> requestCommonPermissions() async {
    return await _requester.requestCommonPermissions();
  }
  
  /// 请求媒体权限组合
  Future<Map<Permission, PermissionResult>> requestMediaPermissions() async {
    return await _requester.requestMediaPermissions();
  }
  
  /// 请求位置权限组合
  Future<Map<Permission, PermissionResult>> requestLocationPermissions() async {
    return await _requester.requestLocationPermissions();
  }
  
  // UI控制相关方法
  
  /// 设置沉浸式状态栏
  void setImmersiveStatusBar({
    Color? statusBarColor,
    Brightness? statusBarBrightness,
    Color? navigationBarColor,
    Brightness? navigationBarIconBrightness,
  }) {
    _uiController.setImmersiveStatusBar(
      statusBarColor: statusBarColor,
      statusBarBrightness: statusBarBrightness,
      navigationBarColor: navigationBarColor,
      navigationBarIconBrightness: navigationBarIconBrightness,
    );
  }
  
  /// 设置浅色状态栏
  void setLightStatusBar() {
    _uiController.setLightStatusBar();
  }
  
  /// 设置深色状态栏
  void setDarkStatusBar() {
    _uiController.setDarkStatusBar();
  }
  
  /// 隐藏状态栏
  void hideStatusBar() {
    _uiController.hideStatusBar();
  }
  
  /// 显示状态栏
  void showStatusBar() {
    _uiController.showStatusBar();
  }
  
  /// 全屏模式
  void setFullScreen() {
    _uiController.setFullScreen();
  }
  
  /// 退出全屏模式
  void exitFullScreen() {
    _uiController.exitFullScreen();
  }
}