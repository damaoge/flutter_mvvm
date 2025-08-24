/// 网络异常类
class NetworkException implements Exception {
  final int code;
  final String message;
  final String? details;
  final NetworkExceptionType type;
  
  const NetworkException({
    required this.code,
    required this.message,
    this.details,
    required this.type,
  });
  
  /// 网络连接异常
  factory NetworkException.noInternet() {
    return const NetworkException(
      code: -1,
      message: '网络连接不可用，请检查网络设置',
      type: NetworkExceptionType.noInternet,
    );
  }
  
  /// 超时异常
  factory NetworkException.timeout(String message) {
    return NetworkException(
      code: -2,
      message: message,
      type: NetworkExceptionType.timeout,
    );
  }
  
  /// 服务器异常
  factory NetworkException.server(int statusCode, String message) {
    return NetworkException(
      code: statusCode,
      message: message,
      type: NetworkExceptionType.server,
    );
  }
  
  /// 请求取消异常
  factory NetworkException.cancel(String message) {
    return NetworkException(
      code: -3,
      message: message,
      type: NetworkExceptionType.cancel,
    );
  }
  
  /// 解析异常
  factory NetworkException.parse(String message) {
    return NetworkException(
      code: -4,
      message: message,
      type: NetworkExceptionType.parse,
    );
  }
  
  /// 未知异常
  factory NetworkException.unknown(String message) {
    return NetworkException(
      code: -999,
      message: message,
      type: NetworkExceptionType.unknown,
    );
  }
  
  /// 权限异常
  factory NetworkException.unauthorized() {
    return const NetworkException(
      code: 401,
      message: '未授权访问，请重新登录',
      type: NetworkExceptionType.unauthorized,
    );
  }
  
  /// 禁止访问异常
  factory NetworkException.forbidden() {
    return const NetworkException(
      code: 403,
      message: '禁止访问，权限不足',
      type: NetworkExceptionType.forbidden,
    );
  }
  
  /// 资源不存在异常
  factory NetworkException.notFound() {
    return const NetworkException(
      code: 404,
      message: '请求的资源不存在',
      type: NetworkExceptionType.notFound,
    );
  }
  
  /// 服务器内部错误
  factory NetworkException.internalServerError() {
    return const NetworkException(
      code: 500,
      message: '服务器内部错误，请稍后重试',
      type: NetworkExceptionType.server,
    );
  }
  
  /// 服务不可用
  factory NetworkException.serviceUnavailable() {
    return const NetworkException(
      code: 503,
      message: '服务暂时不可用，请稍后重试',
      type: NetworkExceptionType.server,
    );
  }
  
  /// 获取用户友好的错误信息
  String get userFriendlyMessage {
    switch (type) {
      case NetworkExceptionType.noInternet:
        return '网络连接不可用，请检查网络设置';
      case NetworkExceptionType.timeout:
        return '网络请求超时，请重试';
      case NetworkExceptionType.server:
        if (code >= 500) {
          return '服务器繁忙，请稍后重试';
        } else if (code == 404) {
          return '请求的资源不存在';
        } else if (code == 403) {
          return '权限不足，无法访问';
        } else {
          return message;
        }
      case NetworkExceptionType.unauthorized:
        return '登录已过期，请重新登录';
      case NetworkExceptionType.forbidden:
        return '权限不足，无法访问';
      case NetworkExceptionType.notFound:
        return '请求的资源不存在';
      case NetworkExceptionType.cancel:
        return '请求已取消';
      case NetworkExceptionType.parse:
        return '数据解析失败';
      case NetworkExceptionType.unknown:
      default:
        return '网络请求失败，请重试';
    }
  }
  
  @override
  String toString() {
    return 'NetworkException(code: $code, message: $message, type: $type, details: $details)';
  }
}

/// 网络异常类型
enum NetworkExceptionType {
  /// 无网络连接
  noInternet,
  
  /// 请求超时
  timeout,
  
  /// 服务器错误
  server,
  
  /// 未授权
  unauthorized,
  
  /// 禁止访问
  forbidden,
  
  /// 资源不存在
  notFound,
  
  /// 请求取消
  cancel,
  
  /// 数据解析错误
  parse,
  
  /// 未知错误
  unknown,
}

/// 网络异常扩展
extension NetworkExceptionTypeExtension on NetworkExceptionType {
  /// 获取异常类型名称
  String get name {
    switch (this) {
      case NetworkExceptionType.noInternet:
        return '网络连接异常';
      case NetworkExceptionType.timeout:
        return '请求超时';
      case NetworkExceptionType.server:
        return '服务器错误';
      case NetworkExceptionType.unauthorized:
        return '未授权访问';
      case NetworkExceptionType.forbidden:
        return '禁止访问';
      case NetworkExceptionType.notFound:
        return '资源不存在';
      case NetworkExceptionType.cancel:
        return '请求取消';
      case NetworkExceptionType.parse:
        return '数据解析错误';
      case NetworkExceptionType.unknown:
        return '未知错误';
    }
  }
  
  /// 是否可以重试
  bool get canRetry {
    switch (this) {
      case NetworkExceptionType.noInternet:
      case NetworkExceptionType.timeout:
      case NetworkExceptionType.server:
        return true;
      case NetworkExceptionType.unauthorized:
      case NetworkExceptionType.forbidden:
      case NetworkExceptionType.notFound:
      case NetworkExceptionType.cancel:
      case NetworkExceptionType.parse:
      case NetworkExceptionType.unknown:
        return false;
    }
  }
}