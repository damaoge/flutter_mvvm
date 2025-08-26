import '../entities/user_entity.dart';

/// 认证仓储接口 - 领域层
abstract class IAuthRepository {
  /// 用户登录
  /// 
  /// [email] 用户邮箱
  /// [password] 用户密码
  /// [rememberMe] 是否记住登录状态
  /// 
  /// 返回认证结果
  Future<AuthResultEntity> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  /// 用户注册
  /// 
  /// [name] 用户姓名
  /// [email] 用户邮箱
  /// [password] 用户密码
  /// [confirmPassword] 确认密码
  /// 
  /// 返回认证结果
  Future<AuthResultEntity> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  });

  /// 用户登出
  /// 
  /// 返回是否成功登出
  Future<bool> logout();

  /// 获取当前用户
  /// 
  /// 返回当前登录的用户，如果未登录则返回null
  Future<UserEntity?> getCurrentUser();

  /// 检查是否已登录
  /// 
  /// 返回用户是否已登录
  Future<bool> isLoggedIn();

  /// 刷新访问令牌
  /// 
  /// 返回是否成功刷新
  Future<bool> refreshToken();

  /// 忘记密码
  /// 
  /// [email] 用户邮箱
  /// 
  /// 返回是否成功发送重置邮件
  Future<bool> forgotPassword(String email);

  /// 重置密码
  /// 
  /// [token] 重置令牌
  /// [newPassword] 新密码
  /// [confirmPassword] 确认新密码
  /// 
  /// 返回是否成功重置密码
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });

  /// 更新用户信息
  /// 
  /// [user] 更新的用户信息
  /// 
  /// 返回更新后的用户信息
  Future<UserEntity?> updateProfile(UserEntity user);

  /// 更改密码
  /// 
  /// [currentPassword] 当前密码
  /// [newPassword] 新密码
  /// [confirmPassword] 确认新密码
  /// 
  /// 返回是否成功更改密码
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });

  /// 验证邮箱
  /// 
  /// [token] 验证令牌
  /// 
  /// 返回是否成功验证邮箱
  Future<bool> verifyEmail(String token);

  /// 重新发送验证邮件
  /// 
  /// 返回是否成功发送验证邮件
  Future<bool> resendVerificationEmail();

  /// 删除账户
  /// 
  /// [password] 用户密码确认
  /// 
  /// 返回是否成功删除账户
  Future<bool> deleteAccount(String password);

  /// 获取用户会话信息
  /// 
  /// 返回会话是否有效
  Future<bool> validateSession();

  /// 清除本地认证数据
  /// 
  /// 清除所有本地存储的认证相关数据
  Future<void> clearAuthData();

  /// 获取访问令牌
  /// 
  /// 返回当前的访问令牌
  Future<String?> getAccessToken();

  /// 获取刷新令牌
  /// 
  /// 返回当前的刷新令牌
  Future<String?> getRefreshToken();

  /// 检查令牌是否过期
  /// 
  /// 返回令牌是否已过期
  Future<bool> isTokenExpired();

  /// 获取令牌过期时间
  /// 
  /// 返回令牌的过期时间
  Future<DateTime?> getTokenExpiryTime();
}