import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// 获取当前用户用例
@injectable
class GetCurrentUserUseCase {
  final IAuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  /// 获取当前登录用户
  /// 
  /// 返回当前用户信息，如果未登录则返回null
  Future<UserEntity?> call() async {
    try {
      // 首先检查是否已登录
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (!isLoggedIn) {
        return null;
      }

      // 检查令牌是否过期
      final isTokenExpired = await _authRepository.isTokenExpired();
      if (isTokenExpired) {
        // 尝试刷新令牌
        final refreshSuccess = await _authRepository.refreshToken();
        if (!refreshSuccess) {
          // 刷新失败，清除认证数据
          await _authRepository.clearAuthData();
          return null;
        }
      }

      // 获取当前用户信息
      final user = await _authRepository.getCurrentUser();
      return user;
    } catch (e) {
      // 获取用户信息失败，可能是网络问题或服务器错误
      // 返回null，让调用方处理
      return null;
    }
  }

  /// 检查用户是否已登录
  /// 
  /// 返回用户是否已登录
  Future<bool> isLoggedIn() async {
    try {
      return await _authRepository.isLoggedIn();
    } catch (e) {
      return false;
    }
  }

  /// 验证当前会话
  /// 
  /// 返回会话是否有效
  Future<bool> validateSession() async {
    try {
      // 检查是否已登录
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (!isLoggedIn) {
        return false;
      }

      // 验证会话
      final isValid = await _authRepository.validateSession();
      if (!isValid) {
        // 会话无效，清除认证数据
        await _authRepository.clearAuthData();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}