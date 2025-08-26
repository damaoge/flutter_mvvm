import 'package:flutter_mvvm/core/datasource/base_datasource.dart';
import 'package:flutter_mvvm/core/network/network_manager.dart';
import 'package:injectable/injectable.dart';

/// 认证相关的远程数据源
abstract class IAuthRemoteDataSource {
  Future<Map<String, dynamic>?> login(String email, String password);
  Future<Map<String, dynamic>?> register(String name, String email, String password);
  Future<void> logout();
  Future<Map<String, dynamic>?> getCurrentUser();
  Future<bool> refreshToken();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
}

@LazySingleton(as: IAuthRemoteDataSource)
class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final RemoteDataSource _remoteDataSource;

  AuthRemoteDataSource(this._remoteDataSource);

  @override
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _remoteDataSource.create('/auth/login', {
        'email': email,
        'password': password,
      });
      return response as Map<String, dynamic>?;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    try {
      final response = await _remoteDataSource.create('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
      });
      return response as Map<String, dynamic>?;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.create('/auth/logout', {});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _remoteDataSource.get('/auth/me');
      return response as Map<String, dynamic>?;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final response = await _remoteDataSource.create('/auth/refresh', {});
      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _remoteDataSource.create('/auth/forgot-password', {
        'email': email,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _remoteDataSource.create('/auth/reset-password', {
        'token': token,
        'password': newPassword,
      });
    } catch (e) {
      rethrow;
    }
  }
}