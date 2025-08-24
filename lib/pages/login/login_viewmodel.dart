import 'package:flutter/material.dart';

import 'package:flutter_mvvm/core/base/base_viewmodel.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'package:flutter_mvvm/core/services/auth_service.dart';
import 'package:flutter_mvvm/core/services/credential_service.dart';
import 'package:flutter_mvvm/core/services/validation_service.dart';

/// 登录页面ViewModel
class LoginViewModel extends BaseViewModel {
  // 服务实例
  final AuthService _authService = AuthService.instance;
  final CredentialService _credentialService = CredentialService.instance;
  final ValidationService _validationService = ValidationService.instance;

  // 表单控制器
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // 密码可见性
  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  // 记住密码
  bool _rememberPassword = false;
  bool get rememberPassword => _rememberPassword;

  @override
  void onInit() {
    super.onInit();
    LoggerUtil.d('LoginViewModel 初始化');
    _loadSavedCredentials();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// 加载保存的凭据
  Future<void> _loadSavedCredentials() async {
    try {
      final credentials = await _credentialService.loadSavedCredentials();
      
      if (credentials.hasEmail) {
        emailController.text = credentials.email;
      }
      
      if (credentials.hasCompleteCredentials) {
        passwordController.text = credentials.password;
        _rememberPassword = credentials.rememberPassword;
      }
      
      notifyListeners();
    } catch (e) {
      LoggerUtil.e('加载保存的凭据失败: $e');
    }
  }

  /// 切换密码可见性
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// 切换记住密码
  void toggleRememberPassword(bool? value) {
    _rememberPassword = value ?? false;
    notifyListeners();
  }

  /// 登录
  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      setLoading(true);

      final email = emailController.text.trim();
      final password = passwordController.text;

      // 调用认证服务进行登录
      final response = await _authService.login(email, password);

      if (response['success'] == true) {
        // 保存凭据（如果选择记住密码）
        await _credentialService.saveCredentials(email, password, _rememberPassword);

  showSuccess('登录成功');
        
        // 跳转到首页
        await Future.delayed(const Duration(milliseconds: 500));
        navigateAndClearStack('/home');
      } else {
        throw Exception('登录失败');
      }
    } catch (e) {
      showError('登录失败: ${e.toString()}');
      LoggerUtil.e('登录失败: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 跳转到注册页面
  void goToRegister() {
    navigateTo('/register');
  }

  /// 忘记密码
  void forgotPassword() {
    showInfo('忘记密码功能待实现', title: '忘记密码');
  }

  /// 邮箱验证
  String? validateEmail(String? value) {
    return _validationService.validateEmail(value);
  }

  /// 密码验证
  String? validatePassword(String? value) {
    return _validationService.validatePassword(value);
  }
}