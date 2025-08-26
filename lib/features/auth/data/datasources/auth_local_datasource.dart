import 'package:flutter_mvvm/core/datasource/base_datasource.dart';
import 'package:flutter_mvvm/core/storage/storage_manager.dart';
import 'package:injectable/injectable.dart';

/// 认证相关的本地数据源
abstract class IAuthLocalDataSource {
  Future<Map<String, dynamic>?> getCachedUser();
  Future<void> cacheUser(Map<String, dynamic> user);
  Future<void> clearCachedUser();
  Future<String?> getAccessToken();
  Future<void> saveAccessToken(String token);
  Future<String?> getRefreshToken();
  Future<void> saveRefreshToken(String token);
  Future<void> clearTokens();
  Future<bool> isLoggedIn();
  Future<void> saveCredentials(String email, String password);
  Future<Map<String, String>?> getSavedCredentials();
  Future<void> clearSavedCredentials();
}

@LazySingleton(as: IAuthLocalDataSource)
class AuthLocalDataSource implements IAuthLocalDataSource {
  final LocalDataSource _localDataSource;
  
  static const String _userKey = 'cached_user';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _credentialsKey = 'saved_credentials';
  static const String _loginStatusKey = 'is_logged_in';

  AuthLocalDataSource(this._localDataSource);

  @override
  Future<Map<String, dynamic>?> getCachedUser() async {
    try {
      final userData = await _localDataSource.get(_userKey);
      return userData as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheUser(Map<String, dynamic> user) async {
    try {
      await _localDataSource.save(_userKey, user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await _localDataSource.delete(_userKey);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final token = await _localDataSource.get(_accessTokenKey);
      return token as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await _localDataSource.save(_accessTokenKey, token);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final token = await _localDataSource.get(_refreshTokenKey);
      return token as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await _localDataSource.save(_refreshTokenKey, token);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      await _localDataSource.delete(_accessTokenKey);
      await _localDataSource.delete(_refreshTokenKey);
      await _localDataSource.save(_loginStatusKey, false);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final status = await _localDataSource.get(_loginStatusKey);
      if (status == null) return false;
      
      // 同时检查是否有有效的访问令牌
      final accessToken = await getAccessToken();
      return status as bool && accessToken != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> saveCredentials(String email, String password) async {
    try {
      await _localDataSource.save(_credentialsKey, {
        'email': email,
        'password': password,
        'savedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final credentials = await _localDataSource.get(_credentialsKey);
      if (credentials == null) return null;
      
      final credMap = credentials as Map<String, dynamic>;
      return {
        'email': credMap['email'] as String,
        'password': credMap['password'] as String,
      };
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearSavedCredentials() async {
    try {
      await _localDataSource.delete(_credentialsKey);
    } catch (e) {
      rethrow;
    }
  }
  
  /// 设置登录状态
  Future<void> setLoginStatus(bool isLoggedIn) async {
    try {
      await _localDataSource.save(_loginStatusKey, isLoggedIn);
    } catch (e) {
      rethrow;
    }
  }
}