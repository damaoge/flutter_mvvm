import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_mvvm/core/datasource/base_datasource.dart';

/// 远程数据源实现
@LazySingleton(as: RemoteDataSource)
class RemoteDataSourceImpl implements RemoteDataSource {
  final Dio _dio;

  RemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      }
      return null;
    } on DioException catch (e) {
      throw NetworkException(_handleDioError(e));
    } catch (e) {
      throw DataSourceException('远程数据获取失败: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data.containsKey('data')) {
          final listData = data['data'];
          if (listData is List) {
            return listData.cast<Map<String, dynamic>>();
          }
        }
        return [];
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(_handleDioError(e));
    } catch (e) {
      throw DataSourceException('远程数据列表获取失败: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> create(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw DataSourceException('创建数据失败: HTTP ${response.statusCode}');
    } on DioException catch (e) {
      throw NetworkException(_handleDioError(e));
    } catch (e) {
      throw DataSourceException('创建数据失败: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> update(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw DataSourceException('更新数据失败: HTTP ${response.statusCode}');
    } on DioException catch (e) {
      throw NetworkException(_handleDioError(e));
    } catch (e) {
      throw DataSourceException('更新数据失败: $e');
    }
  }

  @override
  Future<bool> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      throw NetworkException(_handleDioError(e));
    } catch (e) {
      throw DataSourceException('删除数据失败: $e');
    }
  }

  @override
  Future<int> count(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('count')) {
          return data['count'] as int;
        } else if (data is int) {
          return data;
        }
      }
      return 0;
    } on DioException catch (e) {
      throw NetworkException(_handleDioError(e));
    } catch (e) {
      throw DataSourceException('获取数据数量失败: $e');
    }
  }

  @override
  Future<bool> sync() async {
    try {
      final response = await _dio.post('/sync');
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw NetworkException(_handleDioError(e));
    } catch (e) {
      throw DataSourceException('数据同步失败: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUpdatedSince(DateTime timestamp) async {
    try {
      final response = await _dio.get(
        '/sync/updated',
        queryParameters: {'since': timestamp.toIso8601String()},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map && data.containsKey('data')) {
          final listData = data['data'];
          if (listData is List) {
            return listData.cast<Map<String, dynamic>>();
          }
        }
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException(_handleDioError(e));
    } catch (e) {
      throw DataSourceException('获取更新数据失败: $e');
    }
  }

  @override
  Future<bool> uploadPendingChanges(List<Map<String, dynamic>> changes) async {
    try {
      final response = await _dio.post(
        '/sync/upload',
        data: {'changes': changes},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw NetworkException(_handleDioError(e));
    } catch (e) {
      throw DataSourceException('上传待同步数据失败: $e');
    }
  }

  /// 处理Dio错误
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时';
      case DioExceptionType.sendTimeout:
        return '发送超时';
      case DioExceptionType.receiveTimeout:
        return '接收超时';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 400:
            return '请求参数错误';
          case 401:
            return '未授权访问';
          case 403:
            return '禁止访问';
          case 404:
            return '资源不存在';
          case 500:
            return '服务器内部错误';
          case 502:
            return '网关错误';
          case 503:
            return '服务不可用';
          default:
            return '服务器错误: $statusCode';
        }
      case DioExceptionType.cancel:
        return '请求已取消';
      case DioExceptionType.connectionError:
        return '网络连接错误';
      case DioExceptionType.badCertificate:
        return '证书验证失败';
      case DioExceptionType.unknown:
      default:
        return '未知网络错误: ${e.message}';
    }
  }
}