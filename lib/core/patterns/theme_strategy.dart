import 'package:flutter/material.dart';

/// 主题切换策略接口
abstract class ThemeToggleStrategy {
  /// 执行主题切换逻辑
  ThemeMode execute(ThemeMode currentTheme, BuildContext? context);
  
  /// 获取策略名称
  String get name;
}

/// 浅色到深色主题切换策略
class LightToDarkStrategy implements ThemeToggleStrategy {
  @override
  ThemeMode execute(ThemeMode currentTheme, BuildContext? context) {
    return ThemeMode.dark;
  }
  
  @override
  String get name => '切换到深色主题';
}

/// 深色到浅色主题切换策略
class DarkToLightStrategy implements ThemeToggleStrategy {
  @override
  ThemeMode execute(ThemeMode currentTheme, BuildContext? context) {
    return ThemeMode.light;
  }
  
  @override
  String get name => '切换到浅色主题';
}

/// 系统主题切换策略
class SystemThemeToggleStrategy implements ThemeToggleStrategy {
  @override
  ThemeMode execute(ThemeMode currentTheme, BuildContext? context) {
    // 根据当前系统主题决定切换方向
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
  }
  
  @override
  String get name => '根据系统主题切换';
}

/// 主题切换策略工厂
class ThemeToggleStrategyFactory {
  static final Map<ThemeMode, ThemeToggleStrategy> _strategies = {
    ThemeMode.light: LightToDarkStrategy(),
    ThemeMode.dark: DarkToLightStrategy(),
    ThemeMode.system: SystemThemeToggleStrategy(),
  };
  
  /// 获取主题切换策略
  static ThemeToggleStrategy getStrategy(ThemeMode currentTheme) {
    final strategy = _strategies[currentTheme];
    if (strategy == null) {
      throw ArgumentError('不支持的主题模式: $currentTheme');
    }
    return strategy;
  }
  
  /// 注册自定义策略
  static void registerStrategy(ThemeMode themeMode, ThemeToggleStrategy strategy) {
    _strategies[themeMode] = strategy;
  }
  
  /// 获取所有可用策略
  static Map<ThemeMode, ThemeToggleStrategy> get availableStrategies => 
      Map.unmodifiable(_strategies);
}

/// 主题信息策略接口
abstract class ThemeInfoStrategy {
  /// 获取主题名称
  String getName(ThemeMode themeMode);
  
  /// 检查是否为深色主题
  bool isDarkMode(ThemeMode themeMode, BuildContext? context);
}

/// 默认主题信息策略
class DefaultThemeInfoStrategy implements ThemeInfoStrategy {
  @override
  String getName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return '浅色主题';
      case ThemeMode.dark:
        return '深色主题';
      case ThemeMode.system:
        return '跟随系统';
    }
  }
  
  @override
  bool isDarkMode(ThemeMode themeMode, BuildContext? context) {
    switch (themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        if (context != null) {
          return Theme.of(context).brightness == Brightness.dark;
        }
        // 如果没有context，使用系统亮度
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
  }
}

/// 多语言主题信息策略
class LocalizedThemeInfoStrategy implements ThemeInfoStrategy {
  final Map<String, Map<ThemeMode, String>> _localizedNames;
  final String _currentLocale;
  
  LocalizedThemeInfoStrategy({
    required Map<String, Map<ThemeMode, String>> localizedNames,
    required String currentLocale,
  }) : _localizedNames = localizedNames,
       _currentLocale = currentLocale;
  
  @override
  String getName(ThemeMode themeMode) {
    final localeNames = _localizedNames[_currentLocale];
    if (localeNames != null && localeNames.containsKey(themeMode)) {
      return localeNames[themeMode]!;
    }
    
    // 回退到默认策略
    return DefaultThemeInfoStrategy().getName(themeMode);
  }
  
  @override
  bool isDarkMode(ThemeMode themeMode, BuildContext? context) {
    // 深色模式检查逻辑与语言无关，使用默认策略
    return DefaultThemeInfoStrategy().isDarkMode(themeMode, context);
  }
}