import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

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

/// UI模式策略接口
abstract class UIModeStrategy {
  /// 应用UI模式
  void apply({Color? statusBarColor, Color? navigationBarColor});
  
  /// 获取模式名称
  String get name;
  
  /// 获取模式描述
  String get description;
  
  /// 是否支持自定义颜色
  bool get supportsCustomColors;
}

/// 正常模式策略
class NormalModeStrategy implements UIModeStrategy {
  @override
  void apply({Color? statusBarColor, Color? navigationBarColor}) {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: statusBarColor ?? Colors.white,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          navigationBarColor: navigationBarColor ?? Colors.white,
          navigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.grey[300],
        ),
      );
      
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      
      LoggerUtil.i('应用正常UI模式');
    } catch (e) {
      LoggerUtil.e('应用正常UI模式失败: $e');
    }
  }
  
  @override
  String get name => '正常模式';
  
  @override
  String get description => '显示所有系统UI元素，适合常规应用界面';
  
  @override
  bool get supportsCustomColors => true;
}

/// 沉浸式模式策略
class ImmersiveModeStrategy implements UIModeStrategy {
  @override
  void apply({Color? statusBarColor, Color? navigationBarColor}) {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: statusBarColor ?? Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          navigationBarColor: navigationBarColor ?? Colors.transparent,
          navigationBarIconBrightness: Brightness.light,
        ),
      );
      
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
      );
      
      LoggerUtil.i('应用沉浸式UI模式');
    } catch (e) {
      LoggerUtil.e('应用沉浸式UI模式失败: $e');
    }
  }
  
  @override
  String get name => '沉浸式模式';
  
  @override
  String get description => '隐藏系统UI，提供沉浸式体验，适合游戏和媒体应用';
  
  @override
  bool get supportsCustomColors => true;
}

/// 全屏模式策略
class FullscreenModeStrategy implements UIModeStrategy {
  @override
  void apply({Color? statusBarColor, Color? navigationBarColor}) {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          navigationBarColor: Colors.transparent,
          navigationBarIconBrightness: Brightness.light,
        ),
      );
      
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [],
      );
      
      LoggerUtil.i('应用全屏UI模式');
    } catch (e) {
      LoggerUtil.e('应用全屏UI模式失败: $e');
    }
  }
  
  @override
  String get name => '全屏模式';
  
  @override
  String get description => '完全隐藏系统UI，适合视频播放和演示';
  
  @override
  bool get supportsCustomColors => false;
}

/// 边缘到边缘模式策略
class EdgeToEdgeModeStrategy implements UIModeStrategy {
  @override
  void apply({Color? statusBarColor, Color? navigationBarColor}) {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          navigationBarColor: Colors.transparent,
          navigationBarIconBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        ),
      );
      
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
      
      LoggerUtil.i('应用边缘到边缘UI模式');
    } catch (e) {
      LoggerUtil.e('应用边缘到边缘UI模式失败: $e');
    }
  }
  
  @override
  String get name => '边缘到边缘模式';
  
  @override
  String get description => '内容延伸到屏幕边缘，适合现代Material Design应用';
  
  @override
  bool get supportsCustomColors => false;
}

/// UI模式策略工厂
class UIModeStrategyFactory {
  static final Map<UIMode, UIModeStrategy> _strategies = {
    UIMode.normal: NormalModeStrategy(),
    UIMode.immersive: ImmersiveModeStrategy(),
    UIMode.fullscreen: FullscreenModeStrategy(),
    UIMode.edgeToEdge: EdgeToEdgeModeStrategy(),
  };
  
  /// 获取UI模式策略
  static UIModeStrategy getStrategy(UIMode mode) {
    final strategy = _strategies[mode];
    if (strategy == null) {
      throw ArgumentError('不支持的UI模式: $mode');
    }
    return strategy;
  }
  
  /// 注册自定义策略
  static void registerStrategy(UIMode mode, UIModeStrategy strategy) {
    _strategies[mode] = strategy;
    LoggerUtil.i('注册自定义UI模式策略: ${mode.name}');
  }
  
  /// 获取所有可用策略
  static Map<UIMode, UIModeStrategy> get availableStrategies => 
      Map.unmodifiable(_strategies);
  
  /// 根据应用场景推荐UI模式
  static UIMode recommendMode({
    required bool isMediaApp,
    required bool isGameApp,
    required bool needsImmersion,
    required bool followsMaterialDesign,
  }) {
    if (isGameApp || (isMediaApp && needsImmersion)) {
      return UIMode.immersive;
    }
    
    if (isMediaApp) {
      return UIMode.fullscreen;
    }
    
    if (followsMaterialDesign) {
      return UIMode.edgeToEdge;
    }
    
    return UIMode.normal;
  }
}

/// UI模式配置
class UIModeConfig {
  final UIMode mode;
  final Color? statusBarColor;
  final Color? navigationBarColor;
  final bool autoApply;
  final Duration? transitionDuration;
  
  const UIModeConfig({
    required this.mode,
    this.statusBarColor,
    this.navigationBarColor,
    this.autoApply = true,
    this.transitionDuration,
  });
  
  /// 预定义配置
  static const UIModeConfig defaultConfig = UIModeConfig(
    mode: UIMode.normal,
    statusBarColor: Colors.white,
    navigationBarColor: Colors.white,
  );
  
  static const UIModeConfig darkConfig = UIModeConfig(
    mode: UIMode.normal,
    statusBarColor: Color(0xFF121212),
    navigationBarColor: Color(0xFF121212),
  );
  
  static const UIModeConfig immersiveConfig = UIModeConfig(
    mode: UIMode.immersive,
    transitionDuration: Duration(milliseconds: 300),
  );
  
  static const UIModeConfig materialConfig = UIModeConfig(
    mode: UIMode.edgeToEdge,
  );
}

/// UI模式管理器
class UIModeManager {
  static final UIModeManager _instance = UIModeManager._internal();
  static UIModeManager get instance => _instance;
  
  UIModeManager._internal();
  
  UIMode _currentMode = UIMode.normal;
  UIModeConfig? _currentConfig;
  
  /// 获取当前UI模式
  UIMode get currentMode => _currentMode;
  
  /// 获取当前配置
  UIModeConfig? get currentConfig => _currentConfig;
  
  /// 应用UI模式
  void applyMode(UIModeConfig config) {
    try {
      final strategy = UIModeStrategyFactory.getStrategy(config.mode);
      
      if (config.autoApply) {
        strategy.apply(
          statusBarColor: config.statusBarColor,
          navigationBarColor: config.navigationBarColor,
        );
      }
      
      _currentMode = config.mode;
      _currentConfig = config;
      
      LoggerUtil.i('UI模式已切换为: ${strategy.name}');
    } catch (e) {
      LoggerUtil.e('应用UI模式失败: $e');
      rethrow;
    }
  }
  
  /// 快速设置模式
  void setMode(UIMode mode, {Color? statusBarColor, Color? navigationBarColor}) {
    final config = UIModeConfig(
      mode: mode,
      statusBarColor: statusBarColor,
      navigationBarColor: navigationBarColor,
    );
    applyMode(config);
  }
  
  /// 恢复到正常模式
  void restoreNormalMode() {
    applyMode(UIModeConfig.defaultConfig);
  }
  
  /// 根据主题自动配置
  void applyThemeBasedMode(bool isDarkTheme) {
    final config = isDarkTheme ? UIModeConfig.darkConfig : UIModeConfig.defaultConfig;
    applyMode(config);
  }
}