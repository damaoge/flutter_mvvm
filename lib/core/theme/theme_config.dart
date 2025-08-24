import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 应用主题配置
class ThemeConfig {
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
  
  // 圆角半径
  static const double borderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  
  // 阴影
  static const double elevation = 2.0;
  
  // 字体大小
  static const double fontSizeDisplayLarge = 32.0;
  static const double fontSizeDisplayMedium = 28.0;
  static const double fontSizeDisplaySmall = 24.0;
  static const double fontSizeHeadlineLarge = 22.0;
  static const double fontSizeHeadlineMedium = 20.0;
  static const double fontSizeHeadlineSmall = 18.0;
  static const double fontSizeTitleLarge = 16.0;
  static const double fontSizeTitleMedium = 14.0;
  static const double fontSizeTitleSmall = 12.0;
  static const double fontSizeBodyLarge = 16.0;
  static const double fontSizeBodyMedium = 14.0;
  static const double fontSizeBodySmall = 12.0;
  static const double fontSizeLabelLarge = 14.0;
  static const double fontSizeLabelMedium = 12.0;
  static const double fontSizeLabelSmall = 10.0;
}

/// 主题颜色方案
class ThemeColors {
  /// 浅色主题颜色方案
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: ThemeConfig.primaryColor,
    primaryContainer: ThemeConfig.primaryColorLight,
    secondary: ThemeConfig.accentColor,
    secondaryContainer: ThemeConfig.accentColorLight,
    surface: ThemeConfig.surfaceLight,
    background: ThemeConfig.backgroundLight,
    error: ThemeConfig.errorColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: ThemeConfig.textPrimaryLight,
    onBackground: ThemeConfig.textPrimaryLight,
    onError: Colors.white,
  );
  
  /// 深色主题颜色方案
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: ThemeConfig.primaryColor,
    primaryContainer: ThemeConfig.primaryColorDark,
    secondary: ThemeConfig.accentColor,
    secondaryContainer: ThemeConfig.accentColorDark,
    surface: ThemeConfig.surfaceDark,
    background: ThemeConfig.backgroundDark,
    error: ThemeConfig.errorColorDark,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: ThemeConfig.textPrimaryDark,
    onBackground: ThemeConfig.textPrimaryDark,
    onError: Colors.black,
  );
}

/// 主题文本样式
class ThemeTextStyles {
  /// 浅色主题文本样式
  static const TextTheme lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      color: ThemeConfig.textPrimaryLight,
      fontSize: ThemeConfig.fontSizeDisplayLarge,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: ThemeConfig.textPrimaryLight,
      fontSize: ThemeConfig.fontSizeDisplayMedium,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(
      color: ThemeConfig.textPrimaryLight,
      fontSize: ThemeConfig.fontSizeDisplaySmall,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: TextStyle(
      color: ThemeConfig.textPrimaryLight,
      fontSize: ThemeConfig.fontSizeHeadlineLarge,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      color: ThemeConfig.textPrimaryLight,
      fontSize: ThemeConfig.fontSizeHeadlineMedium,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      color: ThemeConfig.textPrimaryLight,
      fontSize: ThemeConfig.fontSizeHeadlineSmall,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: ThemeConfig.textPrimaryLight,
      fontSize: ThemeConfig.fontSizeTitleLarge,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      color: ThemeConfig.textPrimaryLight,
      fontSize: ThemeConfig.fontSizeTitleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      color: ThemeConfig.textPrimaryLight,
      fontSize: ThemeConfig.fontSizeTitleSmall,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      color: ThemeConfig.textPrimaryLight,
      fontSize: ThemeConfig.fontSizeBodyLarge,
    ),
    bodyMedium: TextStyle(
      color: ThemeConfig.textPrimaryLight,
      fontSize: ThemeConfig.fontSizeBodyMedium,
    ),
    bodySmall: TextStyle(
      color: ThemeConfig.textSecondaryLight,
      fontSize: ThemeConfig.fontSizeBodySmall,
    ),
    labelLarge: TextStyle(
      color: ThemeConfig.textPrimaryLight,
      fontSize: ThemeConfig.fontSizeLabelLarge,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      color: ThemeConfig.textSecondaryLight,
      fontSize: ThemeConfig.fontSizeLabelMedium,
    ),
    labelSmall: TextStyle(
      color: ThemeConfig.textSecondaryLight,
      fontSize: ThemeConfig.fontSizeLabelSmall,
    ),
  );
  
  /// 深色主题文本样式
  static const TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      color: ThemeConfig.textPrimaryDark,
      fontSize: ThemeConfig.fontSizeDisplayLarge,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: ThemeConfig.textPrimaryDark,
      fontSize: ThemeConfig.fontSizeDisplayMedium,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: TextStyle(
      color: ThemeConfig.textPrimaryDark,
      fontSize: ThemeConfig.fontSizeDisplaySmall,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: TextStyle(
      color: ThemeConfig.textPrimaryDark,
      fontSize: ThemeConfig.fontSizeHeadlineLarge,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      color: ThemeConfig.textPrimaryDark,
      fontSize: ThemeConfig.fontSizeHeadlineMedium,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      color: ThemeConfig.textPrimaryDark,
      fontSize: ThemeConfig.fontSizeHeadlineSmall,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: ThemeConfig.textPrimaryDark,
      fontSize: ThemeConfig.fontSizeTitleLarge,
      fontWeight: FontWeight.w500,
    ),
    titleMedium: TextStyle(
      color: ThemeConfig.textPrimaryDark,
      fontSize: ThemeConfig.fontSizeTitleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: TextStyle(
      color: ThemeConfig.textPrimaryDark,
      fontSize: ThemeConfig.fontSizeTitleSmall,
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: TextStyle(
      color: ThemeConfig.textPrimaryDark,
      fontSize: ThemeConfig.fontSizeBodyLarge,
    ),
    bodyMedium: TextStyle(
      color: ThemeConfig.textPrimaryDark,
      fontSize: ThemeConfig.fontSizeBodyMedium,
    ),
    bodySmall: TextStyle(
      color: ThemeConfig.textSecondaryDark,
      fontSize: ThemeConfig.fontSizeBodySmall,
    ),
    labelLarge: TextStyle(
      color: ThemeConfig.textPrimaryDark,
      fontSize: ThemeConfig.fontSizeLabelLarge,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      color: ThemeConfig.textSecondaryDark,
      fontSize: ThemeConfig.fontSizeLabelMedium,
    ),
    labelSmall: TextStyle(
      color: ThemeConfig.textSecondaryDark,
      fontSize: ThemeConfig.fontSizeLabelSmall,
    ),
  );
}