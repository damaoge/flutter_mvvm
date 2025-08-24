import 'package:flutter/material.dart';
import 'theme_config.dart';
import 'theme_data_builder.dart';
import 'theme_state_manager.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 主题管理器
/// 提供深色/浅色主题切换功能的统一入口
class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  static ThemeManager get instance => _instance;
  
  late final ThemeStateManager _stateManager;
  
  ThemeManager._internal() {
    _stateManager = ThemeStateManager();
  }
  
  /// 初始化主题管理器
  Future<void> init() async {
    try {
      await _stateManager.init();
      LoggerUtil.i('主题管理器初始化完成');
    } catch (e) {
      LoggerUtil.e('主题管理器初始化失败: $e');
      rethrow;
    }
  }
  
  /// 获取当前主题模式
  ThemeMode get currentTheme => _stateManager.currentTheme;
  
  /// 设置主题模式
  Future<void> setTheme(ThemeMode themeMode) async {
    await _stateManager.setTheme(themeMode);
  }
  
  /// 切换到浅色主题
  Future<void> setLightTheme() async {
    await _stateManager.setTheme(ThemeMode.light);
  }
  
  /// 切换到深色主题
  Future<void> setDarkTheme() async {
    await _stateManager.setTheme(ThemeMode.dark);
  }
  
  /// 切换到系统主题
  Future<void> setSystemTheme() async {
    await _stateManager.setTheme(ThemeMode.system);
  }
  
  /// 切换主题（在浅色和深色之间切换）
  Future<void> toggleTheme() async {
    await _stateManager.toggleTheme();
  }
  
  /// 检查当前是否为深色主题
  bool isDarkMode(BuildContext context) {
    return _stateManager.isDarkMode(context);
  }
  
  /// 获取浅色主题数据
  ThemeData get lightTheme => ThemeDataBuilder.buildLightTheme();
  
  /// 获取深色主题数据
  ThemeData get darkTheme => ThemeDataBuilder.buildDarkTheme();
  
  /// 获取主题模式名称
  String getThemeModeName() {
    return _stateManager.getThemeModeName();
  }
}