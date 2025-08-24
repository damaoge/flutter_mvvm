import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'package:flutter_mvvm/core/patterns/ui_mode_strategy.dart';

/// UI控制服务
/// 专门负责系统UI的控制，包括状态栏、导航栏等
class UIController {
  static final UIController _instance = UIController._internal();
  static UIController get instance => _instance;
  
  final UIModeManager _modeManager = UIModeManager.instance;
  
  UIController._internal();
  
  /// 获取当前UI模式
  UIMode get currentMode => _modeManager.currentMode;
  
  /// 应用UI模式配置
  void applyModeConfig(UIModeConfig config) {
    _modeManager.applyMode(config);
  }
  
  /// 设置UI模式
  void setUIMode(UIMode mode, {Color? statusBarColor, Color? navigationBarColor}) {
    _modeManager.setMode(mode, statusBarColor: statusBarColor, navigationBarColor: navigationBarColor);
  }
  
  /// 根据主题自动配置UI模式
  void applyThemeBasedMode(bool isDarkTheme) {
    _modeManager.applyThemeBasedMode(isDarkTheme);
  }
  
  /// 恢复到正常模式
  void restoreNormalMode() {
    _modeManager.restoreNormalMode();
  }
  
  /// 设置沉浸式状态栏
  void setImmersiveStatusBar({
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
  
  /// 设置浅色状态栏（保持向后兼容）
  void setLightStatusBar() {
    setUIMode(UIMode.normal, statusBarColor: Colors.white, navigationBarColor: Colors.white);
  }
  
  /// 设置深色状态栏（保持向后兼容）
  void setDarkStatusBar() {
    setUIMode(UIMode.normal, statusBarColor: const Color(0xFF121212), navigationBarColor: const Color(0xFF121212));
  }
  
  /// 设置沉浸式模式
  void setImmersiveMode({Color? statusBarColor, Color? navigationBarColor}) {
    setUIMode(UIMode.immersive, statusBarColor: statusBarColor, navigationBarColor: navigationBarColor);
  }
  
  /// 设置全屏模式
  void setFullscreenMode() {
    setUIMode(UIMode.fullscreen);
  }
  
  /// 设置边缘到边缘模式
  void setEdgeToEdgeMode() {
    setUIMode(UIMode.edgeToEdge);
  }
  
  /// 原始设置沉浸式状态栏方法（保持向后兼容）
  void setImmersiveStatusBar({
    Color? statusBarColor,
    Brightness? statusBarBrightness,
    Color? navigationBarColor,
    Brightness? navigationBarIconBrightness,
  }) {
    setImmersiveStatusBar(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      navigationBarColor: Colors.black,
      navigationBarIconBrightness: Brightness.light,
    );
  }
  
  /// 设置自适应状态栏（根据主题）
  void setAdaptiveStatusBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    if (isDark) {
      setDarkStatusBar();
    } else {
      setLightStatusBar();
    }
  }
  
  /// 设置自定义状态栏样式
  void setCustomStatusBar({
    required Color statusBarColor,
    required Color navigationBarColor,
    required Brightness statusBarIconBrightness,
    required Brightness navigationBarIconBrightness,
  }) {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: statusBarColor,
          statusBarIconBrightness: statusBarIconBrightness,
          navigationBarColor: navigationBarColor,
          navigationBarIconBrightness: navigationBarIconBrightness,
        ),
      );
      
      LoggerUtil.i('设置自定义状态栏样式完成');
    } catch (e) {
      LoggerUtil.e('设置自定义状态栏样式失败: $e');
    }
  }
  
  /// 隐藏状态栏
  void hideStatusBar() {
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
  void showStatusBar() {
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
  
  /// 隐藏导航栏
  void hideNavigationBar() {
    try {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top],
      );
      LoggerUtil.i('隐藏导航栏完成');
    } catch (e) {
      LoggerUtil.e('隐藏导航栏失败: $e');
    }
  }
  
  /// 显示导航栏
  void showNavigationBar() {
    try {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      LoggerUtil.i('显示导航栏完成');
    } catch (e) {
      LoggerUtil.e('显示导航栏失败: $e');
    }
  }
  
  /// 全屏模式（隐藏所有系统UI）
  void setFullScreen() {
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      LoggerUtil.i('设置全屏模式完成');
    } catch (e) {
      LoggerUtil.e('设置全屏模式失败: $e');
    }
  }
  
  /// 沉浸式全屏模式（可通过手势调出系统UI）
  void setImmersiveFullScreen() {
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      LoggerUtil.i('设置沉浸式全屏模式完成');
    } catch (e) {
      LoggerUtil.e('设置沉浸式全屏模式失败: $e');
    }
  }
  
  /// 退出全屏模式
  void exitFullScreen() {
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
  
  /// 设置边缘到边缘模式
  void setEdgeToEdge() {
    try {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
      LoggerUtil.i('设置边缘到边缘模式完成');
    } catch (e) {
      LoggerUtil.e('设置边缘到边缘模式失败: $e');
    }
  }
  
  /// 设置屏幕方向
  void setOrientation(List<DeviceOrientation> orientations) {
    try {
      SystemChrome.setPreferredOrientations(orientations);
      LoggerUtil.i('设置屏幕方向完成: ${orientations.map((o) => o.name).join(', ')}');
    } catch (e) {
      LoggerUtil.e('设置屏幕方向失败: $e');
    }
  }
  
  /// 设置竖屏模式
  void setPortraitMode() {
    setOrientation([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  
  /// 设置横屏模式
  void setLandscapeMode() {
    setOrientation([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
  
  /// 设置自动旋转
  void setAutoRotate() {
    setOrientation(DeviceOrientation.values);
  }
  
  /// 锁定当前方向
  void lockCurrentOrientation() {
    // 这里需要获取当前方向，简化处理
    setOrientation([DeviceOrientation.portraitUp]);
  }
  
  /// 重置所有UI设置为默认
  void resetToDefault() {
    try {
      // 重置系统UI模式
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      
      // 重置状态栏样式
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          navigationBarColor: Colors.white,
          navigationBarIconBrightness: Brightness.dark,
        ),
      );
      
      // 重置屏幕方向
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      
      LoggerUtil.i('重置UI设置为默认完成');
    } catch (e) {
      LoggerUtil.e('重置UI设置失败: $e');
    }
  }
  
  /// 获取当前系统UI模式描述
  String getCurrentModeDescription() {
    // 这里简化处理，实际应用中可以通过其他方式获取当前状态
    return '当前UI模式';
  }
}

/// UI模式枚举
enum UIMode {
  /// 正常模式
  normal,
  
  /// 沉浸式模式
  immersive,
  
  /// 全屏模式
  fullscreen,
  
  /// 边缘到边缘模式
  edgeToEdge,
}

/// UI模式扩展
extension UIModeExtension on UIMode {
  /// 获取模式名称
  String get name {
    switch (this) {
      case UIMode.normal:
        return '正常模式';
      case UIMode.immersive:
        return '沉浸式模式';
      case UIMode.fullscreen:
        return '全屏模式';
      case UIMode.edgeToEdge:
        return '边缘到边缘模式';
    }
  }
  
  /// 获取模式描述
  String get description {
    switch (this) {
      case UIMode.normal:
        return '显示所有系统UI元素';
      case UIMode.immersive:
        return '隐藏系统UI，提供沉浸式体验';
      case UIMode.fullscreen:
        return '完全隐藏系统UI';
      case UIMode.edgeToEdge:
        return '内容延伸到屏幕边缘';
    }
  }
}