import 'package:flutter/material.dart';
import 'package:flutter_mvvm/core/storage/storage_manager.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'package:flutter_mvvm/core/patterns/theme_strategy.dart';

/// 主题状态管理器
class ThemeStateManager {
  static const String _themeKey = 'app_theme_mode';
  
  ThemeMode _currentTheme = ThemeMode.system;
  ThemeInfoStrategy _infoStrategy = DefaultThemeInfoStrategy();
  
  /// 获取当前主题模式
  ThemeMode get currentTheme => _currentTheme;
  
  /// 设置主题信息策略
  void setThemeInfoStrategy(ThemeInfoStrategy strategy) {
    _infoStrategy = strategy;
    LoggerUtil.i('主题信息策略已更新: ${strategy.runtimeType}');
  }
  
  /// 初始化主题状态
  Future<void> init() async {
    try {
      await _loadThemeFromStorage();
      LoggerUtil.i('主题状态管理器初始化完成，当前主题: $_currentTheme');
    } catch (e) {
      LoggerUtil.e('主题状态管理器初始化失败: $e');
      _currentTheme = ThemeMode.system;
    }
  }
  
  /// 设置主题模式
  Future<void> setTheme(ThemeMode themeMode) async {
    try {
      _currentTheme = themeMode;
      await _saveThemeToStorage();
      LoggerUtil.i('主题已切换为: $themeMode');
    } catch (e) {
      LoggerUtil.e('设置主题失败: $e');
      rethrow;
    }
  }
  
  /// 切换主题（在浅色和深色之间切换）
  Future<ThemeMode> toggleTheme() async {
    try {
      final strategy = ThemeToggleStrategyFactory.getStrategy(_currentTheme);
      final newTheme = strategy.execute(_currentTheme, null);
      
      await setTheme(newTheme);
      LoggerUtil.i('主题切换完成: ${strategy.name}');
      return newTheme;
    } catch (e) {
      LoggerUtil.e('主题切换失败: $e');
      rethrow;
    }
  }
  
  /// 检查当前是否为深色主题
  bool isDarkMode(BuildContext context) {
    return _infoStrategy.isDarkMode(_currentTheme, context);
  }
  
  /// 获取主题模式名称
  String getThemeModeName() {
    return _infoStrategy.getName(_currentTheme);
  }
  
  /// 从存储中加载主题设置
  Future<void> _loadThemeFromStorage() async {
    try {
      final themeIndex = await StorageManager.instance.getInt(_themeKey);
      if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
        _currentTheme = ThemeMode.values[themeIndex];
      }
    } catch (e) {
      LoggerUtil.e('从存储加载主题失败: $e');
      throw Exception('加载主题设置失败: $e');
    }
  }
  
  /// 保存主题设置到存储
  Future<void> _saveThemeToStorage() async {
    try {
      await StorageManager.instance.setInt(_themeKey, _currentTheme.index);
    } catch (e) {
      LoggerUtil.e('保存主题到存储失败: $e');
      throw Exception('保存主题设置失败: $e');
    }
  }
}

/// 主题提供者
class ThemeProvider extends ChangeNotifier {
  final ThemeStateManager _stateManager = ThemeStateManager();
  
  ThemeMode get themeMode => _stateManager.currentTheme;
  
  /// 初始化主题提供者
  Future<void> init() async {
    try {
      await _stateManager.init();
      notifyListeners();
    } catch (e) {
      LoggerUtil.e('主题提供者初始化失败: $e');
      rethrow;
    }
  }
  
  /// 设置主题模式
  Future<void> setTheme(ThemeMode themeMode) async {
    try {
      await _stateManager.setTheme(themeMode);
      notifyListeners();
    } catch (e) {
      LoggerUtil.e('设置主题失败: $e');
      rethrow;
    }
  }
  
  /// 切换到浅色主题
  Future<void> setLightTheme() async {
    await setTheme(ThemeMode.light);
  }
  
  /// 切换到深色主题
  Future<void> setDarkTheme() async {
    await setTheme(ThemeMode.dark);
  }
  
  /// 切换到系统主题
  Future<void> setSystemTheme() async {
    await setTheme(ThemeMode.system);
  }
  
  /// 切换主题
  Future<void> toggleTheme() async {
    try {
      await _stateManager.toggleTheme();
      notifyListeners();
    } catch (e) {
      LoggerUtil.e('切换主题失败: $e');
      rethrow;
    }
  }
  
  /// 检查当前是否为深色主题
  bool isDarkMode(BuildContext context) {
    return _stateManager.isDarkMode(context);
  }
  
  /// 获取主题模式名称
  String getThemeModeName() {
    return _stateManager.getThemeModeName();
  }
}