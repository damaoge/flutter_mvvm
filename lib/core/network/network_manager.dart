import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_mvvm/core/base/app_config.dart';
import 'package:flutter_mvvm/core/base/base_model.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'network_interceptor.dart';
import 'network_exception.dart';

/// 网络管理器
class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  static NetworkManager get instance => _instance;
  
  late Dio _dio;
  final Connectivity _connectivity = Connectivity();
  
  NetworkManager._internal();
  
  /// 初始化网络管理器
  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.environment.baseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        sendTimeout: Duration(milliseconds: AppConfig.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // 添加拦截器
    _dio.interceptors.add(NetworkInterceptor());
    
    if (AppConfig.isDebug) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (obj) => LoggerUtil.d(obj),
        ),
      );
    }
    
    LoggerUtil.i('网络管理器初始化完成');
  }
  
  /// 检查网络连接
  Future<bool> checkConnectivity() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      LoggerUtil.e('检查网络连接失败: $e');
      return false;
    }
  }
  
  /// GET请求
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      await _checkNetworkConnectivity();
      
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// POST请求
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      await _checkNetworkConnectivity();
      
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// PUT请求
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      await _checkNetworkConnectivity();
      
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// DELETE请求
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      await _checkNetworkConnectivity();
      
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 上传文件
  Future<T> upload<T>(
    String path,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      await _checkNetworkConnectivity();
      
      final file = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      );
      
      final formData = FormData.fromMap({
        'file': file,
        ...?data,
      });
      
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 下载文件
  Future<void> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await _checkNetworkConnectivity();
      
      await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
        queryParameters: queryParameters,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  /// 检查网络连接
  Future<void> _checkNetworkConnectivity() async {
    final isConnected = await checkConnectivity();
    if (!isConnected) {
      throw NetworkException.noInternet();
    }
  }
  
  /// 处理响应数据
  T _handleResponse<T>(Response response, T Function(dynamic)? fromJson) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (fromJson != null) {
        return fromJson(response.data);
      } else {
        return response.data as T;
      }
    } else {
      throw NetworkException.server(
        response.statusCode ?? -1,
        response.statusMessage ?? '服务器错误',
      );
    }
  }
  
  /// 处理错误
  NetworkException _handleError(dynamic error) {
    LoggerUtil.e('网络请求错误: $error');
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return NetworkException.timeout('连接超时');
        case DioExceptionType.sendTimeout:
          return NetworkException.timeout('发送超时');
        case DioExceptionType.receiveTimeout:
          return NetworkException.timeout('接收超时');
        case DioExceptionType.badResponse:
          return NetworkException.server(
            error.response?.statusCode ?? -1,
            error.response?.statusMessage ?? '服务器错误',
          );
        case DioExceptionType.cancel:
          return NetworkException.cancel('请求已取消');
        case DioExceptionType.connectionError:
          return NetworkException.noInternet();
        default:
          return NetworkException.unknown(error.message ?? '未知错误');
      }
    } else if (error is SocketException) {
      return NetworkException.noInternet();
    } else if (error is NetworkException) {
      return error;
    } else {
      return NetworkException.unknown(error.toString());
    }
  }
  
  /// 设置Token
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  /// 清除Token
  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }
  
  /// 设置基础URL
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }
  
  /// 获取Dio实例
  Dio get dio => _dio;
}