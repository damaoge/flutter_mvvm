import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_config.dart';

/// 主题数据构建器
class ThemeDataBuilder {
  /// 构建浅色主题
  static ThemeData buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: ThemeConfig.primaryColor,
      scaffoldBackgroundColor: ThemeConfig.backgroundLight,
      backgroundColor: ThemeConfig.backgroundLight,
      cardColor: ThemeConfig.surfaceLight,
      dividerColor: ThemeConfig.dividerLight,
      colorScheme: ThemeColors.lightColorScheme,
      textTheme: ThemeTextStyles.lightTextTheme,
      appBarTheme: _buildLightAppBarTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      inputDecorationTheme: _buildLightInputDecorationTheme(),
      cardTheme: _buildCardTheme(ThemeConfig.surfaceLight),
    );
  }
  
  /// 构建深色主题
  static ThemeData buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: ThemeConfig.primaryColor,
      scaffoldBackgroundColor: ThemeConfig.backgroundDark,
      backgroundColor: ThemeConfig.backgroundDark,
      cardColor: ThemeConfig.surfaceDark,
      dividerColor: ThemeConfig.dividerDark,
      colorScheme: ThemeColors.darkColorScheme,
      textTheme: ThemeTextStyles.darkTextTheme,
      appBarTheme: _buildDarkAppBarTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      inputDecorationTheme: _buildDarkInputDecorationTheme(),
      cardTheme: _buildCardTheme(ThemeConfig.surfaceDark),
    );
  }
  
  /// 构建浅色AppBar主题
  static AppBarTheme _buildLightAppBarTheme() {
    return const AppBarTheme(
      backgroundColor: ThemeConfig.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }
  
  /// 构建深色AppBar主题
  static AppBarTheme _buildDarkAppBarTheme() {
    return const AppBarTheme(
      backgroundColor: ThemeConfig.surfaceDark,
      foregroundColor: ThemeConfig.textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }
  
  /// 构建按钮主题
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeConfig.primaryColor,
        foregroundColor: Colors.white,
        elevation: ThemeConfig.elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius),
        ),
      ),
    );
  }
  
  /// 构建浅色输入框主题
  static InputDecorationTheme _buildLightInputDecorationTheme() {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius),
        borderSide: const BorderSide(color: ThemeConfig.dividerLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius),
        borderSide: const BorderSide(color: ThemeConfig.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius),
        borderSide: const BorderSide(color: ThemeConfig.errorColor),
      ),
      filled: true,
      fillColor: ThemeConfig.surfaceLight,
    );
  }
  
  /// 构建深色输入框主题
  static InputDecorationTheme _buildDarkInputDecorationTheme() {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius),
        borderSide: const BorderSide(color: ThemeConfig.dividerDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius),
        borderSide: const BorderSide(color: ThemeConfig.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius),
        borderSide: const BorderSide(color: ThemeConfig.errorColorDark),
      ),
      filled: true,
      fillColor: ThemeConfig.surfaceDark,
    );
  }
  
  /// 构建卡片主题
  static CardTheme _buildCardTheme(Color surfaceColor) {
    return CardTheme(
      color: surfaceColor,
      elevation: ThemeConfig.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.cardBorderRadius),
      ),
    );
  }
}