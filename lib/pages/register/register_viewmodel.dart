import 'package:flutter/material.dart';

import 'package:flutter_mvvm/core/base/base_viewmodel.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'package:flutter_mvvm/core/services/auth_service.dart';
import 'package:flutter_mvvm/core/services/validation_service.dart';

/// 注册页面ViewModel
class RegisterViewModel extends BaseViewModel {
  // 服务实例
  final AuthService _authService = AuthService.instance;
  final ValidationService _validationService = ValidationService.instance;

  // 表单控制器
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // 密码可见性
  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  bool _isConfirmPasswordVisible = false;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  // 同意条款
  bool _agreeToTerms = false;
  bool get agreeToTerms => _agreeToTerms;

  @override
  void onInit() {
    super.onInit();
    LoggerUtil.d('RegisterViewModel 初始化');
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// 切换密码可见性
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// 切换确认密码可见性
  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  /// 切换同意条款
  void toggleAgreeToTerms(bool? value) {
    _agreeToTerms = value ?? false;
    notifyListeners();
  }

  /// 注册
  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      showWarning('请先同意用户协议和隐私政策', title: '提示');
      return;
    }

    try {
      setLoading(true);

      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;

      // 调用认证服务进行注册
      final response = await _authService.register(name, email, password);

      if (response['success'] == true) {
        showSuccess('注册成功');
        
        // 跳转到登录页面
        await Future.delayed(const Duration(milliseconds: 500));
        navigateAndClearStack('/login');
      } else {
        throw Exception('注册失败');
      }
    } catch (e) {
      showError('注册失败: ${e.toString()}');
      LoggerUtil.e('注册失败: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 跳转到登录页面
  void goToLogin() {
    navigateBack();
  }

  /// 查看用户协议
  void viewTermsOfService() {
    showInfo('用户协议功能待实现', title: '用户协议');
  }

  /// 查看隐私政策
  void viewPrivacyPolicy() {
    showInfo('隐私政策功能待实现', title: '隐私政策');
  }

  /// 姓名验证
  String? validateName(String? value) {
    return _validationService.validateName(value);
  }

  /// 邮箱验证
  String? validateEmail(String? value) {
    return _validationService.validateEmail(value);
  }

  /// 密码验证
  String? validatePassword(String? value) {
    return _validationService.validatePassword(value);
  }

  /// 确认密码验证
  String? validateConfirmPassword(String? value) {
    return _validationService.validateConfirmPassword(passwordController.text, value);
  }
}