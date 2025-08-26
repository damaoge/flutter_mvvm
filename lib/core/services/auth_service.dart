import 'package:injectable/injectable.dart';
import 'package:flutter_mvvm/core/storage/storage_manager.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 认证服务接口
abstract class IAuthService {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String name, String email, String password);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<Map<String, dynamic>?> getCurrentUser();
  Future<String?> getUserToken();
}

/// 认证服务实现
/// 负责处理用户登录、注册、登出等认证相关操作
@LazySingleton(as: IAuthService)
class AuthService implements IAuthService {
  final IStorageManager _storageManager;
  
  AuthService(this._storageManager);

  /// 登录
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      LoggerUtil.d('开始登录: $email');
      
      // 模拟网络请求
      await Future.delayed(const Duration(seconds: 2));
      
      // 这里应该调用实际的登录API
      // final response = await NetworkManager.instance.post('/auth/login', {
      //   'email': email,
      //   'password': password,
      // });
      
      // 模拟登录成功
      final mockResponse = {
        'success': true,
        'data': {
          'token': 'mock_token_123456',
          'user': {
            'id': 1,
            'name': 'Flutter用户',
            'email': email,
            'avatar': '',
          },
        },
      };

      if (mockResponse['success'] == true) {
        await _saveLoginInfo(mockResponse['data'] as Map<String, dynamic>);
        LoggerUtil.d('用户登录成功: $email');
        return mockResponse;
      } else {
        throw Exception('登录失败');
      }
    } catch (e) {
      LoggerUtil.e('登录失败: $e');
      rethrow;
    }
  }

  /// 注册
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      LoggerUtil.d('开始注册: $email');
      
      // 模拟网络请求
      await Future.delayed(const Duration(seconds: 2));
      
      // 这里应该调用实际的注册API
      // final response = await NetworkManager.instance.post('/auth/register', {
      //   'name': name,
      //   'email': email,
      //   'password': password,
      // });
      
      // 模拟注册成功
      final mockResponse = {
        'success': true,
        'data': {
          'token': 'mock_token_123456',
          'user': {
            'id': 1,
            'name': name,
            'email': email,
            'avatar': '',
          },
        },
      };

      if (mockResponse['success'] == true) {
        await _saveLoginInfo(mockResponse['data'] as Map<String, dynamic>);
        LoggerUtil.d('用户注册成功: $email');
        return mockResponse;
      } else {
        throw Exception('注册失败');
      }
    } catch (e) {
      LoggerUtil.e('注册失败: $e');
      rethrow;
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      LoggerUtil.d('用户登出');
      
      // 清除本地存储的用户信息
      await _storageManager.remove('user_token');
      await _storageManager.remove('user_info');
      
      LoggerUtil.d('用户登出成功');
    } catch (e) {
      LoggerUtil.e('登出失败: $e');
      rethrow;
    }
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    try {
      final token = await _storageManager.getString('user_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      LoggerUtil.e('检查登录状态失败: $e');
      return false;
    }
  }

  /// 获取当前用户信息
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      return await _storageManager.getJson('user_info');
    } catch (e) {
      LoggerUtil.e('获取用户信息失败: $e');
      return null;
    }
  }

  /// 获取用户Token
  Future<String?> getUserToken() async {
    try {
      return await _storageManager.getString('user_token');
    } catch (e) {
      LoggerUtil.e('获取用户Token失败: $e');
      return null;
    }
  }

  /// 保存登录信息
  Future<void> _saveLoginInfo(Map<String, dynamic> data) async {
    await _storageManager.setString('user_token', data['token']);
    await _storageManager.setJson('user_info', data['user']);
  }
}