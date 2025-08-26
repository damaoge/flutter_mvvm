import 'package:flutter_mvvm/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_mvvm/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_mvvm/features/auth/data/models/user_model.dart';
import 'package:flutter_mvvm/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_mvvm/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_mvvm/core/exceptions/exceptions.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IAuthRepository)
class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<UserEntity?> login(String email, String password, {bool rememberMe = false}) async {
    try {
      // 尝试远程登录
      final response = await _remoteDataSource.login(email, password);
      
      if (response != null) {
        // 解析认证响应
        final authResponse = AuthResponseModel.fromJson(response);
        
        // 保存令牌
        await _localDataSource.saveAccessToken(authResponse.accessToken);
        await _localDataSource.saveRefreshToken(authResponse.refreshToken);
        
        // 缓存用户信息
        await _localDataSource.cacheUser(authResponse.user.toJson());
        
        // 设置登录状态
        await (_localDataSource as AuthLocalDataSource).setLoginStatus(true);
        
        // 如果选择记住密码，保存凭据
        if (rememberMe) {
          await _localDataSource.saveCredentials(email, password);
        }
        
        // 转换为实体并返回
        return _mapUserModelToEntity(authResponse.user);
      }
      
      return null;
    } on NetworkException {
      // 网络异常时，尝试使用缓存的凭据
      final savedCredentials = await _localDataSource.getSavedCredentials();
      if (savedCredentials != null && 
          savedCredentials['email'] == email && 
          savedCredentials['password'] == password) {
        
        final cachedUser = await _localDataSource.getCachedUser();
        if (cachedUser != null) {
          return _mapUserDataToEntity(cachedUser);
        }
      }
      rethrow;
    } catch (e) {
      throw AuthException('登录失败: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> register(String name, String email, String password) async {
    try {
      final response = await _remoteDataSource.register(name, email, password);
      
      if (response != null) {
        final authResponse = AuthResponseModel.fromJson(response);
        
        // 保存令牌和用户信息
        await _localDataSource.saveAccessToken(authResponse.accessToken);
        await _localDataSource.saveRefreshToken(authResponse.refreshToken);
        await _localDataSource.cacheUser(authResponse.user.toJson());
        await (_localDataSource as AuthLocalDataSource).setLoginStatus(true);
        
        return _mapUserModelToEntity(authResponse.user);
      }
      
      return null;
    } catch (e) {
      throw AuthException('注册失败: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // 尝试远程注销
      await _remoteDataSource.logout();
    } catch (e) {
      // 即使远程注销失败，也要清除本地数据
    } finally {
      // 清除本地数据
      await _localDataSource.clearTokens();
      await _localDataSource.clearCachedUser();
      await _localDataSource.clearSavedCredentials();
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      // 首先检查本地缓存
      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser != null) {
        // 尝试从远程获取最新用户信息
        try {
          final remoteUser = await _remoteDataSource.getCurrentUser();
          if (remoteUser != null) {
            // 更新缓存
            await _localDataSource.cacheUser(remoteUser);
            return _mapUserDataToEntity(remoteUser);
          }
        } catch (e) {
          // 远程获取失败，使用缓存数据
        }
        
        return _mapUserDataToEntity(cachedUser);
      }
      
      // 如果没有缓存，尝试从远程获取
      final remoteUser = await _remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await _localDataSource.cacheUser(remoteUser);
        return _mapUserDataToEntity(remoteUser);
      }
      
      return null;
    } catch (e) {
      throw AuthException('获取用户信息失败: ${e.toString()}');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = await _localDataSource.isLoggedIn();
      if (!isLoggedIn) return false;
      
      // 检查令牌是否有效
      final accessToken = await _localDataSource.getAccessToken();
      if (accessToken == null) {
        // 尝试刷新令牌
        return await refreshToken();
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _localDataSource.getRefreshToken();
      if (refreshToken == null) return false;
      
      final success = await _remoteDataSource.refreshToken();
      if (!success) {
        // 刷新失败，清除本地数据
        await logout();
        return false;
      }
      
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
    } catch (e) {
      throw AuthException('发送重置密码邮件失败: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await _remoteDataSource.resetPassword(token, newPassword);
    } catch (e) {
      throw AuthException('重置密码失败: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProfile(UserEntity user) async {
    try {
      // 这里需要实现更新用户资料的逻辑
      // 暂时抛出未实现异常
      throw UnimplementedError('updateProfile not implemented yet');
    } catch (e) {
      throw AuthException('更新用户资料失败: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      // 这里需要实现修改密码的逻辑
      // 暂时抛出未实现异常
      throw UnimplementedError('changePassword not implemented yet');
    } catch (e) {
      throw AuthException('修改密码失败: ${e.toString()}');
    }
  }

  /// 将UserModel转换为UserEntity
  UserEntity _mapUserModelToEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      avatar: model.avatar,
      phone: model.phone,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      metadata: model.metadata,
    );
  }

  /// 将用户数据Map转换为UserEntity
  UserEntity _mapUserDataToEntity(Map<String, dynamic> userData) {
    return UserEntity(
      id: userData['id'] as String,
      name: userData['name'] as String,
      email: userData['email'] as String,
      avatar: userData['avatar'] as String?,
      phone: userData['phone'] as String?,
      createdAt: DateTime.parse(userData['createdAt'] as String),
      updatedAt: DateTime.parse(userData['updatedAt'] as String),
      metadata: userData['metadata'] as Map<String, dynamic>?,
    );
  }
}