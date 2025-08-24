import 'package:dio/dio.dart';
import 'package:flutter_mvvm/core/base/app_config.dart';
import 'package:flutter_mvvm/core/storage/storage_manager.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 网络拦截器
class NetworkInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 添加通用请求头
    options.headers.addAll({
      'User-Agent': 'Flutter MVVM/${AppConfig.version}',
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'Platform': 'mobile',
    });
    
    // 添加Token
    final token = StorageManager.instance.getString(AppConfig.keyUserToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    LoggerUtil.network(
      options.method,
      options.uri.toString(),
      params: {
        'headers': options.headers,
        'data': options.data,
        'queryParameters': options.queryParameters,
      },
    );
    
    super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    LoggerUtil.network(
      response.requestOptions.method,
      response.requestOptions.uri.toString(),
      response: {
        'statusCode': response.statusCode,
        'data': response.data,
      },
    );
    
    super.onResponse(response, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    LoggerUtil.e(
      '网络请求错误',
      {
        'url': err.requestOptions.uri.toString(),
        'method': err.requestOptions.method,
        'statusCode': err.response?.statusCode,
        'message': err.message,
        'data': err.response?.data,
      },
    );
    
    // 处理Token过期
    if (err.response?.statusCode == 401) {
      _handleTokenExpired();
    }
    
    super.onError(err, handler);
  }
  
  /// 处理Token过期
  void _handleTokenExpired() {
    LoggerUtil.w('Token已过期，清除本地Token');
    StorageManager.instance.remove(AppConfig.keyUserToken);
    StorageManager.instance.remove(AppConfig.keyUserInfo);
    
    // 这里可以添加跳转到登录页面的逻辑
    // AppRouter.toLogin();
  }
}

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  
  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldRetry(err)) {
      _retry(err, handler);
    } else {
      super.onError(err, handler);
    }
  }
  
  /// 判断是否应该重试
  bool _shouldRetry(DioException err) {
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
    
    if (retryCount >= maxRetries) {
      return false;
    }
    
    // 只对特定错误类型进行重试
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
  
  /// 执行重试
  void _retry(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
    err.requestOptions.extra['retryCount'] = retryCount + 1;
    
    LoggerUtil.w('网络请求重试 ${retryCount + 1}/$maxRetries: ${err.requestOptions.uri}');
    
    await Future.delayed(retryDelay);
    
    try {
      final dio = Dio();
      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        onError(e, handler);
      } else {
        handler.reject(err);
      }
    }
  }
}

/// 缓存拦截器
class CacheInterceptor extends Interceptor {
  final Map<String, CacheData> _cache = {};
  final Duration defaultCacheDuration;
  
  CacheInterceptor({
    this.defaultCacheDuration = const Duration(minutes: 5),
  });
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 只对GET请求进行缓存
    if (options.method.toUpperCase() != 'GET') {
      return super.onRequest(options, handler);
    }
    
    final cacheKey = _generateCacheKey(options);
    final cacheData = _cache[cacheKey];
    
    if (cacheData != null && !cacheData.isExpired) {
      LoggerUtil.d('使用缓存数据: $cacheKey');
      handler.resolve(cacheData.response);
      return;
    }
    
    super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 只缓存成功的GET请求
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode == 200) {
      final cacheKey = _generateCacheKey(response.requestOptions);
      final cacheDuration = _getCacheDuration(response.requestOptions);
      
      _cache[cacheKey] = CacheData(
        response: response,
        expireTime: DateTime.now().add(cacheDuration),
      );
      
      LoggerUtil.d('缓存响应数据: $cacheKey');
    }
    
    super.onResponse(response, handler);
  }
  
  /// 生成缓存键
  String _generateCacheKey(RequestOptions options) {
    final uri = options.uri.toString();
    final headers = options.headers.toString();
    return '$uri-$headers'.hashCode.toString();
  }
  
  /// 获取缓存时长
  Duration _getCacheDuration(RequestOptions options) {
    final cacheControl = options.headers['Cache-Control'];
    if (cacheControl != null) {
      final match = RegExp(r'max-age=(\d+)').firstMatch(cacheControl);
      if (match != null) {
        final seconds = int.tryParse(match.group(1) ?? '0') ?? 0;
        return Duration(seconds: seconds);
      }
    }
    return defaultCacheDuration;
  }
  
  /// 清除缓存
  void clearCache() {
    _cache.clear();
    LoggerUtil.d('清除所有网络缓存');
  }
  
  /// 清除过期缓存
  void clearExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) => value.isExpired);
    LoggerUtil.d('清除过期网络缓存');
  }
}

/// 缓存数据模型
class CacheData {
  final Response response;
  final DateTime expireTime;
  
  CacheData({
    required this.response,
    required this.expireTime,
  });
  
  bool get isExpired => DateTime.now().isAfter(expireTime);
}