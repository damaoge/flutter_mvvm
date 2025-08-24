import 'package:flutter_mvvm/core/managers/storage_manager.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 凭据管理服务
/// 负责处理用户凭据的保存、加载和清除
class CredentialService {
  static final CredentialService _instance = CredentialService._internal();
  factory CredentialService() => _instance;
  CredentialService._internal();

  static CredentialService get instance => _instance;

  // 存储键名
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';
  static const String _rememberPasswordKey = 'remember_password';

  /// 保存用户凭据
  Future<void> saveCredentials(String email, String password, bool rememberPassword) async {
    try {
      await StorageManager.instance.setString(_savedEmailKey, email);
      
      if (rememberPassword) {
        await StorageManager.instance.setString(_savedPasswordKey, password);
        await StorageManager.instance.setBool(_rememberPasswordKey, true);
      } else {
        await clearPassword();
      }
      
      LoggerUtil.d('用户凭据保存成功');
    } catch (e) {
      LoggerUtil.e('保存用户凭据失败: $e');
      rethrow;
    }
  }

  /// 加载保存的凭据
  Future<SavedCredentials> loadSavedCredentials() async {
    try {
      final savedEmail = await StorageManager.instance.getString(_savedEmailKey);
      final savedPassword = await StorageManager.instance.getString(_savedPasswordKey);
      final rememberPassword = await StorageManager.instance.getBool(_rememberPasswordKey) ?? false;
      
      return SavedCredentials(
        email: savedEmail ?? '',
        password: (rememberPassword && savedPassword != null) ? savedPassword : '',
        rememberPassword: rememberPassword,
      );
    } catch (e) {
      LoggerUtil.e('加载保存的凭据失败: $e');
      return SavedCredentials.empty();
    }
  }

  /// 清除保存的密码
  Future<void> clearPassword() async {
    try {
      await StorageManager.instance.remove(_savedPasswordKey);
      await StorageManager.instance.setBool(_rememberPasswordKey, false);
      LoggerUtil.d('密码清除成功');
    } catch (e) {
      LoggerUtil.e('清除密码失败: $e');
      rethrow;
    }
  }

  /// 清除所有保存的凭据
  Future<void> clearAllCredentials() async {
    try {
      await StorageManager.instance.remove(_savedEmailKey);
      await StorageManager.instance.remove(_savedPasswordKey);
      await StorageManager.instance.remove(_rememberPasswordKey);
      LoggerUtil.d('所有凭据清除成功');
    } catch (e) {
      LoggerUtil.e('清除所有凭据失败: $e');
      rethrow;
    }
  }

  /// 检查是否有保存的邮箱
  Future<bool> hasSavedEmail() async {
    try {
      final email = await StorageManager.instance.getString(_savedEmailKey);
      return email != null && email.isNotEmpty;
    } catch (e) {
      LoggerUtil.e('检查保存的邮箱失败: $e');
      return false;
    }
  }

  /// 检查是否记住密码
  Future<bool> isRememberPassword() async {
    try {
      return await StorageManager.instance.getBool(_rememberPasswordKey) ?? false;
    } catch (e) {
      LoggerUtil.e('检查记住密码状态失败: $e');
      return false;
    }
  }

  /// 获取保存的邮箱
  Future<String?> getSavedEmail() async {
    try {
      return await StorageManager.instance.getString(_savedEmailKey);
    } catch (e) {
      LoggerUtil.e('获取保存的邮箱失败: $e');
      return null;
    }
  }
}

/// 保存的凭据数据类
class SavedCredentials {
  final String email;
  final String password;
  final bool rememberPassword;

  const SavedCredentials({
    required this.email,
    required this.password,
    required this.rememberPassword,
  });

  /// 创建空的凭据对象
  factory SavedCredentials.empty() {
    return const SavedCredentials(
      email: '',
      password: '',
      rememberPassword: false,
    );
  }

  /// 是否有保存的邮箱
  bool get hasEmail => email.isNotEmpty;

  /// 是否有保存的密码
  bool get hasPassword => password.isNotEmpty;

  /// 是否有完整的凭据
  bool get hasCompleteCredentials => hasEmail && hasPassword && rememberPassword;

  @override
  String toString() {
    return 'SavedCredentials(email: $email, hasPassword: $hasPassword, rememberPassword: $rememberPassword)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedCredentials &&
        other.email == email &&
        other.password == password &&
        other.rememberPassword == rememberPassword;
  }

  @override
  int get hashCode => email.hashCode ^ password.hashCode ^ rememberPassword.hashCode;
}