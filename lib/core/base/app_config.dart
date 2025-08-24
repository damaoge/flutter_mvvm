/// 应用配置类
class AppConfig {
  static const String appName = 'Flutter MVVM';
  static const String version = '1.0.0';
  static const int buildNumber = 1;
  
  // API配置
  static const String baseUrl = 'https://api.example.com';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
  
  // 缓存配置
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int cacheExpireTime = 7 * 24 * 60 * 60 * 1000; // 7天
  
  // 数据库配置
  static const String databaseName = 'flutter_mvvm.db';
  static const int databaseVersion = 1;
  
  // 存储Key
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyUserToken = 'user_token';
  static const String keyUserInfo = 'user_info';
  
  // 页面配置
  static const int pageSize = 20;
  
  // 调试模式
  static const bool isDebug = true;
  
  // 环境配置
  static const Environment environment = Environment.dev;
}

/// 环境枚举
enum Environment {
  dev,
  test,
  prod,
}

/// 环境配置扩展
extension EnvironmentExtension on Environment {
  String get name {
    switch (this) {
      case Environment.dev:
        return '开发环境';
      case Environment.test:
        return '测试环境';
      case Environment.prod:
        return '生产环境';
    }
  }
  
  String get baseUrl {
    switch (this) {
      case Environment.dev:
        return 'https://dev-api.example.com';
      case Environment.test:
        return 'https://test-api.example.com';
      case Environment.prod:
        return 'https://api.example.com';
    }
  }
}