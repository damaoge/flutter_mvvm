import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// 登录用例
@injectable
class LoginUseCase {
  final IAuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  /// 执行登录
  /// 
  /// [params] 登录参数
  /// 
  /// 返回认证结果
  Future<AuthResultEntity> call(LoginParams params) async {
    // 验证输入参数
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return validationResult;
    }

    try {
      // 执行登录
      final result = await _authRepository.login(
        email: params.email,
        password: params.password,
        rememberMe: params.rememberMe,
      );

      return result;
    } catch (e) {
      return AuthResultEntity.failure(
        '登录失败: ${e.toString()}',
        'LOGIN_ERROR',
      );
    }
  }

  /// 验证登录参数
  AuthResultEntity? _validateParams(LoginParams params) {
    // 验证邮箱
    if (params.email.isEmpty) {
      return AuthResultEntity.failure('请输入邮箱地址', 'EMAIL_REQUIRED');
    }

    if (!_isValidEmail(params.email)) {
      return AuthResultEntity.failure('请输入有效的邮箱地址', 'EMAIL_INVALID');
    }

    // 验证密码
    if (params.password.isEmpty) {
      return AuthResultEntity.failure('请输入密码', 'PASSWORD_REQUIRED');
    }

    if (params.password.length < 6) {
      return AuthResultEntity.failure('密码长度不能少于6位', 'PASSWORD_TOO_SHORT');
    }

    return null;
  }

  /// 验证邮箱格式
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

/// 登录参数
class LoginParams {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginParams({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginParams &&
        other.email == email &&
        other.password == password &&
        other.rememberMe == rememberMe;
  }

  @override
  int get hashCode => Object.hash(email, password, rememberMe);

  @override
  String toString() {
    return 'LoginParams(email: $email, password: [HIDDEN], rememberMe: $rememberMe)';
  }
}