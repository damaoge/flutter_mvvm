import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../storage/storage_manager.dart';
import '../utils/logger_util.dart';

/// 主题管理器
/// 提供深色/浅色主题切换功能
class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  static ThemeManager get instance => _instance;
  
  static const String _themeKey = 'app_theme_mode';
  
  ThemeMode _currentTheme = ThemeMode.system;
  
  ThemeManager._internal();
  
  /// 初始化主题管理器
  Future<void> init() async {
    try {
      await _loadThemeFromStorage();
      LoggerUtil.i('主题管理器初始化完成，当前主题: $_currentTheme');
    } catch (e) {
      LoggerUtil.e('主题管理器初始化失败: $e');
      _currentTheme = ThemeMode.system;
    }
  }
  
  /// 获取当前主题模式
  ThemeMode get currentTheme => _currentTheme;
  
  /// 设置主题模式
  Future<void> setTheme(ThemeMode themeMode) async {
    try {
      _currentTheme = themeMode;
      await _saveThemeToStorage();
      _updateSystemUI();
      LoggerUtil.i('主题已切换为: $themeMode');
    } catch (e) {
      LoggerUtil.e('设置主题失败: $e');
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
  
  /// 切换主题（在浅色和深色之间切换）
  Future<void> toggleTheme() async {
    switch (_currentTheme) {
      case ThemeMode.light:
        await setDarkTheme();
        break;
      case ThemeMode.dark:
        await setLightTheme();
        break;
      case ThemeMode.system:
        // 根据当前系统主题决定切换方向
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        if (brightness == Brightness.dark) {
          await setLightTheme();
        } else {
          await setDarkTheme();
        }
        break;
    }
  }
  
  /// 检查当前是否为深色主题
  bool isDarkMode(BuildContext context) {
    switch (_currentTheme) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return Theme.of(context).brightness == Brightness.dark;
    }
  }
  
  /// 从存储中加载主题设置
  Future<void> _loadThemeFromStorage() async {
    try {
      final themeIndex = await StorageManager.instance.getInt(_themeKey);
      if (themeIndex != null) {
        _currentTheme = ThemeMode.values[themeIndex];
      }
    } catch (e) {
      LoggerUtil.e('从存储加载主题失败: $e');
    }
  }
  
  /// 保存主题设置到存储
  Future<void> _saveThemeToStorage() async {
    try {
      await StorageManager.instance.setInt(_themeKey, _currentTheme.index);
    } catch (e) {
      LoggerUtil.e('保存主题到存储失败: $e');
    }
  }
  
  /// 更新系统UI样式
  void _updateSystemUI() {
    // 这里可以根据主题更新状态栏样式
    // 具体实现会在应用启动时根据主题动态设置
  }
}

/// 主题提供者
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  /// 初始化主题提供者
  Future<void> init() async {
    await ThemeManager.instance.init();
    _themeMode = ThemeManager.instance.currentTheme;
    notifyListeners();
  }
  
  /// 设置主题模式
  Future<void> setTheme(ThemeMode themeMode) async {
    await ThemeManager.instance.setTheme(themeMode);
    _themeMode = themeMode;
    notifyListeners();
  }
  
  /// 切换主题
  Future<void> toggleTheme() async {
    await ThemeManager.instance.toggleTheme();
    _themeMode = ThemeManager.instance.currentTheme;
    notifyListeners();
  }
}

/// 应用主题配置
class AppTheme {
  // 主色调
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryColorDark = Color(0xFF1976D2);
  static const Color primaryColorLight = Color(0xFFBBDEFB);
  
  // 辅助色
  static const Color accentColor = Color(0xFFFF4081);
  static const Color accentColorDark = Color(0xFFC51162);
  static const Color accentColorLight = Color(0xFFFF80AB);
  
  // 背景色
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  
  // 表面色
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // 文字色
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  
  // 分割线色
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF2C2C2C);
  
  // 错误色
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color errorColorDark = Color(0xFFCF6679);
  
  // 成功色
  static const Color successColor = Color(0xFF4CAF50);
  static const Color successColorDark = Color(0xFF81C784);
  
  // 警告色
  static const Color warningColor = Color(0xFFFF9800);
  static const Color warningColorDark = Color(0xFFFFB74D);
  
  /// 浅色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundLight,
      backgroundColor: backgroundLight,
      cardColor: surfaceLight,
      dividerColor: dividerLight,
      
      // ColorScheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        primaryContainer: primaryColorLight,
        secondary: accentColor,
        secondaryContainer: accentColorLight,
        surface: surfaceLight,
        background: backgroundLight,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryLight,
        onBackground: textPrimaryLight,
        onError: Colors.white,
      ),
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // 文本主题
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimaryLight, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textPrimaryLight, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textPrimaryLight, fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: textPrimaryLight, fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: textPrimaryLight, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textPrimaryLight, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimaryLight, fontSize: 16, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: textPrimaryLight, fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: textPrimaryLight, fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimaryLight, fontSize: 16),
        bodyMedium: TextStyle(color: textPrimaryLight, fontSize: 14),
        bodySmall: TextStyle(color: textSecondaryLight, fontSize: 12),
        labelLarge: TextStyle(color: textPrimaryLight, fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: textSecondaryLight, fontSize: 12),
        labelSmall: TextStyle(color: textSecondaryLight, fontSize: 10),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        filled: true,
        fillColor: surfaceLight,
      ),
      
      // 卡片主题
      cardTheme: CardTheme(
        color: surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  /// 深色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundDark,
      backgroundColor: backgroundDark,
      cardColor: surfaceDark,
      dividerColor: dividerDark,
      
      // ColorScheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        primaryContainer: primaryColorDark,
        secondary: accentColor,
        secondaryContainer: accentColorDark,
        surface: surfaceDark,
        background: backgroundDark,
        error: errorColorDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
        onBackground: textPrimaryDark,
        onError: Colors.black,
      ),
      
      // AppBar主题
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // 文本主题
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimaryDark, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textPrimaryDark, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textPrimaryDark, fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: textPrimaryDark, fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: textPrimaryDark, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textPrimaryDark, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimaryDark, fontSize: 16, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: textPrimaryDark, fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: textPrimaryDark, fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimaryDark, fontSize: 16),
        bodyMedium: TextStyle(color: textPrimaryDark, fontSize: 14),
        bodySmall: TextStyle(color: textSecondaryDark, fontSize: 12),
        labelLarge: TextStyle(color: textPrimaryDark, fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: textSecondaryDark, fontSize: 12),
        labelSmall: TextStyle(color: textSecondaryDark, fontSize: 10),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColorDark),
        ),
        filled: true,
        fillColor: surfaceDark,
      ),
      
      // 卡片主题
      cardTheme: CardTheme(
        color: surfaceDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}