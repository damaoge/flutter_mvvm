import 'package:flutter/material.dart';
import 'theme_strategy.dart';
import 'cache_factory.dart';
import 'ui_mode_strategy.dart';
import 'package:flutter_mvvm/core/cache/cache_types.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 设计模式使用示例
/// 展示如何使用工厂模式和策略模式优化架构
class PatternUsageExamples {
  
  /// 主题策略模式使用示例
  static void demonstrateThemeStrategy() {
    LoggerUtil.i('=== 主题策略模式示例 ===');
    
    // 1. 使用默认主题信息策略
    final defaultStrategy = DefaultThemeInfoStrategy();
    LoggerUtil.i('浅色主题名称: ${defaultStrategy.getName(ThemeMode.light)}');
    LoggerUtil.i('深色主题名称: ${defaultStrategy.getName(ThemeMode.dark)}');
    
    // 2. 使用多语言主题信息策略
    final localizedNames = {
      'zh_CN': {
        ThemeMode.light: '浅色主题',
        ThemeMode.dark: '深色主题',
        ThemeMode.system: '跟随系统',
      },
      'en_US': {
        ThemeMode.light: 'Light Theme',
        ThemeMode.dark: 'Dark Theme',
        ThemeMode.system: 'Follow System',
      },
    };
    
    final localizedStrategy = LocalizedThemeInfoStrategy(
      localizedNames: localizedNames,
      currentLocale: 'en_US',
    );
    LoggerUtil.i('英文浅色主题名称: ${localizedStrategy.getName(ThemeMode.light)}');
    
    // 3. 使用主题切换策略
    final lightToDarkStrategy = ThemeToggleStrategyFactory.getStrategy(ThemeMode.light);
    final newTheme = lightToDarkStrategy.execute(ThemeMode.light, null);
    LoggerUtil.i('从浅色主题切换到: $newTheme');
    
    // 4. 注册自定义策略
    ThemeToggleStrategyFactory.registerStrategy(
      ThemeMode.light,
      CustomThemeToggleStrategy(),
    );
  }
  
  /// 缓存工厂模式使用示例
  static Future<void> demonstrateCacheFactory() async {
    LoggerUtil.i('=== 缓存工厂模式示例 ===');
    
    // 1. 直接获取特定类型的缓存管理器
    final memoryCache = CacheFactory.getCacheManager(CacheType.memory);
    await memoryCache.set('user_temp', {'id': 1, 'name': 'Test'});
    final userData = await memoryCache.get<Map<String, dynamic>>('user_temp');
    LoggerUtil.i('内存缓存数据: $userData');
    
    // 2. 智能选择缓存类型
    final optimalType = CacheFactory.selectOptimalCacheType(
      dataSize: 1024, // 1KB
      needsPersistence: true,
      frequentAccess: true,
      needsQuery: false,
    );
    LoggerUtil.i('推荐的缓存类型: ${optimalType.name}');
    
    // 3. 获取推荐的缓存管理器
    final recommendedCache = CacheFactory.getRecommendedCacheManager(
      dataSize: 1024 * 1024, // 1MB
      needsPersistence: true,
      frequentAccess: false,
      needsQuery: true,
    );
    
    await recommendedCache.set('large_data', {'data': 'large dataset'});
    LoggerUtil.i('大数据已缓存');
    
    // 4. 使用预定义策略配置
    final fastAccessCache = CacheFactory.getCacheManager(CacheStrategyConfig.fastAccess.primaryCache);
    await fastAccessCache.set('quick_access', 'fast data', expiration: CacheStrategyConfig.fastAccess.defaultExpiration);
    
    // 5. 获取所有缓存统计信息
    final allStats = CacheFactory.getAllCacheStats();
    LoggerUtil.i('所有缓存统计: $allStats');
  }
  
  /// UI模式策略使用示例
  static void demonstrateUIModeStrategy() {
    LoggerUtil.i('=== UI模式策略示例 ===');
    
    // 1. 获取特定UI模式策略
    final immersiveStrategy = UIModeStrategyFactory.getStrategy(UIMode.immersive);
    LoggerUtil.i('沉浸式模式: ${immersiveStrategy.name} - ${immersiveStrategy.description}');
    
    // 2. 应用UI模式
    immersiveStrategy.apply(
      statusBarColor: Colors.transparent,
      navigationBarColor: Colors.black,
    );
    
    // 3. 根据应用场景推荐UI模式
    final recommendedMode = UIModeStrategyFactory.recommendMode(
      isMediaApp: true,
      isGameApp: false,
      needsImmersion: true,
      followsMaterialDesign: false,
    );
    LoggerUtil.i('推荐的UI模式: $recommendedMode');
    
    // 4. 使用UI模式管理器
    final modeManager = UIModeManager.instance;
    
    // 应用预定义配置
    modeManager.applyMode(UIModeConfig.immersiveConfig);
    LoggerUtil.i('当前UI模式: ${modeManager.currentMode}');
    
    // 根据主题自动配置
    modeManager.applyThemeBasedMode(true); // 深色主题
    
    // 5. 注册自定义UI模式策略
    UIModeStrategyFactory.registerStrategy(
      UIMode.normal,
      CustomUIModeStrategy(),
    );
  }
  
  /// 综合使用示例
  static Future<void> demonstrateIntegratedUsage() async {
    LoggerUtil.i('=== 综合使用示例 ===');
    
    // 1. 根据用户偏好配置主题和UI
    final userPreferences = {
      'theme': 'dark',
      'language': 'zh_CN',
      'ui_mode': 'immersive',
    };
    
    // 配置多语言主题策略
    final localizedThemeStrategy = LocalizedThemeInfoStrategy(
      localizedNames: {
        'zh_CN': {
          ThemeMode.light: '浅色主题',
          ThemeMode.dark: '深色主题',
          ThemeMode.system: '跟随系统',
        },
      },
      currentLocale: userPreferences['language']!,
    );
    
    // 应用UI模式
    final uiModeManager = UIModeManager.instance;
    final isDarkTheme = userPreferences['theme'] == 'dark';
    uiModeManager.applyThemeBasedMode(isDarkTheme);
    
    // 2. 智能缓存用户数据
    final userDataSize = 2048; // 2KB
    final userCache = CacheFactory.getRecommendedCacheManager(
      dataSize: userDataSize,
      needsPersistence: true,
      frequentAccess: true,
      needsQuery: false,
    );
    
    await userCache.set('user_preferences', userPreferences, 
        expiration: const Duration(days: 30));
    
    // 3. 缓存大型数据（如图片、文档）
    final largeDataCache = CacheFactory.getRecommendedCacheManager(
      dataSize: 5 * 1024 * 1024, // 5MB
      needsPersistence: true,
      frequentAccess: false,
      needsQuery: true,
    );
    
    await largeDataCache.set('app_resources', {'images': [], 'documents': []});
    
    LoggerUtil.i('综合配置完成');
  }
}

/// 自定义主题切换策略示例
class CustomThemeToggleStrategy implements ThemeToggleStrategy {
  @override
  ThemeMode execute(ThemeMode currentTheme, BuildContext? context) {
    // 自定义逻辑：总是切换到系统主题
    return ThemeMode.system;
  }
  
  @override
  String get name => '切换到系统主题';
}

/// 自定义UI模式策略示例
class CustomUIModeStrategy implements UIModeStrategy {
  @override
  void apply({Color? statusBarColor, Color? navigationBarColor}) {
    // 自定义UI模式实现
    LoggerUtil.i('应用自定义UI模式');
  }
  
  @override
  String get name => '自定义模式';
  
  @override
  String get description => '自定义的UI模式实现';
  
  @override
  bool get supportsCustomColors => true;
}

/// 模式使用指南
class PatternUsageGuide {
  /// 何时使用策略模式
  static const String strategyPatternGuide = '''
策略模式适用场景：
1. 有多种算法或行为需要在运行时选择
2. 需要避免大量的条件判断语句
3. 算法或行为可能会频繁变化
4. 需要支持算法的扩展和替换

本项目中的应用：
- 主题切换逻辑（ThemeToggleStrategy）
- 主题信息获取（ThemeInfoStrategy）
- UI模式控制（UIModeStrategy）
''';
  
  /// 何时使用工厂模式
  static const String factoryPatternGuide = '''
工厂模式适用场景：
1. 对象创建逻辑复杂
2. 需要根据条件创建不同类型的对象
3. 需要统一管理对象的创建
4. 需要隐藏对象创建的细节

本项目中的应用：
- 缓存管理器创建（CacheFactory）
- 智能缓存类型选择
- UI模式策略创建（UIModeStrategyFactory）
''';
  
  /// 性能优化建议
  static const String performanceOptimizationTips = '''
性能优化建议：
1. 缓存策略实例，避免重复创建
2. 使用单例模式管理工厂实例
3. 延迟初始化不常用的策略
4. 合理选择缓存类型以优化性能
5. 避免在UI线程执行耗时的策略操作
''';
}