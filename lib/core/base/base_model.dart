import 'package:json_annotation/json_annotation.dart';

/// 数据模型基类
/// 提供MVVM架构中Model的基础功能
abstract class BaseModel {
  /// 从JSON创建模型实例
  /// 子类需要实现此方法
  static T fromJson<T extends BaseModel>(Map<String, dynamic> json) {
    throw UnimplementedError('子类必须实现fromJson方法');
  }
  
  /// 转换为JSON
  /// 子类需要实现此方法
  Map<String, dynamic> toJson();
  
  /// 复制模型
  /// 子类可以重写此方法
  BaseModel copyWith();
  
  @override
  String toString() {
    return '${runtimeType}(${toJson()})';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is BaseModel && other.toJson().toString() == toJson().toString();
  }
  
  @override
  int get hashCode => toJson().toString().hashCode;
}

/// 响应数据基类
@JsonSerializable(genericArgumentFactories: true)
class BaseResponse<T> {
  @JsonKey(name: 'code')
  final int code;
  
  @JsonKey(name: 'message')
  final String message;
  
  @JsonKey(name: 'data')
  final T? data;
  
  @JsonKey(name: 'timestamp')
  final int? timestamp;
  
  const BaseResponse({
    required this.code,
    required this.message,
    this.data,
    this.timestamp,
  });
  
  /// 是否成功
  bool get isSuccess => code == 200 || code == 0;
  
  /// 是否失败
  bool get isFailure => !isSuccess;
  
  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return BaseResponse<T>(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] == null ? null : fromJsonT(json['data']),
      timestamp: json['timestamp'] as int?,
    );
  }
  
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'code': code,
      'message': message,
      'data': data == null ? null : toJsonT(data as T),
      'timestamp': timestamp,
    };
  }
  
  @override
  String toString() {
    return 'BaseResponse(code: $code, message: $message, data: $data, timestamp: $timestamp)';
  }
}

/// 分页响应数据基类
@JsonSerializable(genericArgumentFactories: true)
class PageResponse<T> {
  @JsonKey(name: 'list')
  final List<T> list;
  
  @JsonKey(name: 'total')
  final int total;
  
  @JsonKey(name: 'page')
  final int page;
  
  @JsonKey(name: 'size')
  final int size;
  
  @JsonKey(name: 'pages')
  final int pages;
  
  const PageResponse({
    required this.list,
    required this.total,
    required this.page,
    required this.size,
    required this.pages,
  });
  
  /// 是否有下一页
  bool get hasNext => page < pages;
  
  /// 是否有上一页
  bool get hasPrev => page > 1;
  
  /// 是否为空
  bool get isEmpty => list.isEmpty;
  
  /// 是否不为空
  bool get isNotEmpty => list.isNotEmpty;
  
  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return PageResponse<T>(
      list: (json['list'] as List<dynamic>)
          .map((e) => fromJsonT(e))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      size: json['size'] as int,
      pages: json['pages'] as int,
    );
  }
  
  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'list': list.map((e) => toJsonT(e)).toList(),
      'total': total,
      'page': page,
      'size': size,
      'pages': pages,
    };
  }
  
  @override
  String toString() {
    return 'PageResponse(list: ${list.length} items, total: $total, page: $page, size: $size, pages: $pages)';
  }
}

/// 错误模型
class ErrorModel extends BaseModel {
  final int code;
  final String message;
  final String? details;
  final DateTime timestamp;
  
  const ErrorModel({
    required this.code,
    required this.message,
    this.details,
    required this.timestamp,
  });
  
  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      code: json['code'] as int,
      message: json['message'] as String,
      details: json['details'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'details': details,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
  
  @override
  ErrorModel copyWith({
    int? code,
    String? message,
    String? details,
    DateTime? timestamp,
  }) {
    return ErrorModel(
      code: code ?? this.code,
      message: message ?? this.message,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
    );
  }
  
  /// 创建网络错误
  factory ErrorModel.network(String message) {
    return ErrorModel(
      code: -1,
      message: message,
      details: '网络连接错误',
      timestamp: DateTime.now(),
    );
  }
  
  /// 创建服务器错误
  factory ErrorModel.server(int code, String message) {
    return ErrorModel(
      code: code,
      message: message,
      details: '服务器错误',
      timestamp: DateTime.now(),
    );
  }
  
  /// 创建未知错误
  factory ErrorModel.unknown(String message) {
    return ErrorModel(
      code: -999,
      message: message,
      details: '未知错误',
      timestamp: DateTime.now(),
    );
  }
}