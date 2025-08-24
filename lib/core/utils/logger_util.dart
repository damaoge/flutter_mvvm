import 'package:logger/logger.dart';
import '../base/app_config.dart';

/// 日志工具类
class LoggerUtil {
  static Logger? _logger;
  
  /// 初始化日志
  static void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      level: AppConfig.isDebug ? Level.debug : Level.info,
    );
  }
  
  /// 调试日志
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConfig.isDebug) {
      _logger?.d(message, error: error, stackTrace: stackTrace);
    }
  }
  
  /// 信息日志
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.i(message, error: error, stackTrace: stackTrace);
  }
  
  /// 警告日志
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.w(message, error: error, stackTrace: stackTrace);
  }
  
  /// 错误日志
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.e(message, error: error, stackTrace: stackTrace);
  }
  
  /// 致命错误日志
  static void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger?.f(message, error: error, stackTrace: stackTrace);
  }
  
  /// 网络请求日志
  static void network(String method, String url, {Map<String, dynamic>? params, dynamic response}) {
    if (AppConfig.isDebug) {
      final buffer = StringBuffer();
      buffer.writeln('🌐 Network Request');
      buffer.writeln('Method: $method');
      buffer.writeln('URL: $url');
      if (params != null && params.isNotEmpty) {
        buffer.writeln('Params: $params');
      }
      if (response != null) {
        buffer.writeln('Response: $response');
      }
      _logger?.d(buffer.toString());
    }
  }
  
  /// 数据库操作日志
  static void database(String operation, String table, {Map<String, dynamic>? data}) {
    if (AppConfig.isDebug) {
      final buffer = StringBuffer();
      buffer.writeln('🗄️ Database Operation');
      buffer.writeln('Operation: $operation');
      buffer.writeln('Table: $table');
      if (data != null && data.isNotEmpty) {
        buffer.writeln('Data: $data');
      }
      _logger?.d(buffer.toString());
    }
  }
  
  /// 缓存操作日志
  static void cache(String operation, String key, {dynamic value}) {
    if (AppConfig.isDebug) {
      final buffer = StringBuffer();
      buffer.writeln('💾 Cache Operation');
      buffer.writeln('Operation: $operation');
      buffer.writeln('Key: $key');
      if (value != null) {
        buffer.writeln('Value: $value');
      }
      _logger?.d(buffer.toString());
    }
  }
  
  /// 路由跳转日志
  static void route(String from, String to, {Map<String, dynamic>? arguments}) {
    if (AppConfig.isDebug) {
      final buffer = StringBuffer();
      buffer.writeln('🧭 Route Navigation');
      buffer.writeln('From: $from');
      buffer.writeln('To: $to');
      if (arguments != null && arguments.isNotEmpty) {
        buffer.writeln('Arguments: $arguments');
      }
      _logger?.d(buffer.toString());
    }
  }
  
  /// 性能监控日志
  static void performance(String operation, Duration duration) {
    if (AppConfig.isDebug) {
      final buffer = StringBuffer();
      buffer.writeln('⚡ Performance Monitor');
      buffer.writeln('Operation: $operation');
      buffer.writeln('Duration: ${duration.inMilliseconds}ms');
      _logger?.d(buffer.toString());
    }
  }
}