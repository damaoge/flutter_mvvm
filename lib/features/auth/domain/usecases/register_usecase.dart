import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// 注册用例
@injectable
class RegisterUseCase {
  final IAuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  /// 执行注册
  /// 
  /// [params] 注册参数
  /// 
  /// 返回认证结果
  Future<AuthResultEntity> call(RegisterParams params) async {
    // 验证输入参数
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return validationResult;
    }

    try {
      // 执行注册
      final result = await _authRepository.register(
        name: params.name,
        email: params.email,
        password: params.password,
        confirmPassword: params.confirmPassword,
      );

      return result;
    } catch (e) {
      return AuthResultEntity.failure(
        '注册失败: ${e.toString()}',
        'REGISTER_ERROR',
      );
    }
  }

  /// 验证注册参数
  AuthResultEntity? _validateParams(RegisterParams params) {
    // 验证姓名
    if (params.name.isEmpty) {
      return AuthResultEntity.failure('请输入姓名', 'NAME_REQUIRED');
    }

    if (params.name.length < 2) {
      return AuthResultEntity.failure('姓名长度不能少于2位', 'NAME_TOO_SHORT');
    }

    if (params.name.length > 50) {
      return AuthResultEntity.failure('姓名长度不能超过50位', 'NAME_TOO_LONG');
    }

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

    if (params.password.length > 128) {
      return AuthResultEntity.failure('密码长度不能超过128位', 'PASSWORD_TOO_LONG');
    }

    // 验证密码强度
    if (!_isStrongPassword(params.password)) {
      return AuthResultEntity.failure(
        '密码必须包含至少一个大写字母、一个小写字母和一个数字',
        'PASSWORD_WEAK',
      );
    }

    // 验证确认密码
    if (params.confirmPassword.isEmpty) {
      return AuthResultEntity.failure('请确认密码', 'CONFIRM_PASSWORD_REQUIRED');
    }

    if (params.password != params.confirmPassword) {
      return AuthResultEntity.failure('两次输入的密码不一致', 'PASSWORD_MISMATCH');
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

  /// 验证密码强度
  bool _isStrongPassword(String password) {
    // 至少包含一个大写字母
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    // 至少包含一个小写字母
    final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    // 至少包含一个数字
    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    
    return hasUppercase && hasLowercase && hasDigit;
  }
}

/// 注册参数
class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegisterParams &&
        other.name == name &&
        other.email == email &&
        other.password == password &&
        other.confirmPassword == confirmPassword;
  }

  @override
  int get hashCode => Object.hash(name, email, password, confirmPassword);

  @override
  String toString() {
    return 'RegisterParams(name: $name, email: $email, password: [HIDDEN], confirmPassword: [HIDDEN])';
  }
}