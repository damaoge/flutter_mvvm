import 'package:flutter/material.dart';

import 'package:flutter_mvvm/core/base/base_viewmodel.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'package:flutter_mvvm/core/repository/user_repository.dart';
import 'package:flutter_mvvm/core/services/validation_service.dart';
import 'package:flutter_mvvm/core/di/service_locator.dart';

/// 注册页面ViewModel
class RegisterViewModel extends BaseViewModel {
  // Repository和服务实例
  final IUserRepository _userRepository = getIt<IUserRepository>();
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
      showError('请先同意用户协议和隐私政策', title: '注册失败');
      return;
    }

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    await safeExecute(() async {
      LoggerUtil.d('开始注册: $email');
      
      // 调用用户Repository注册
      final user = await _userRepository.register(name, email, password);
      
      if (user != null) {
        showSuccess('注册成功，欢迎 ${user.name}！', title: '注册成功');
        
        // 注册成功后直接跳转到首页
        navigateAndClearStack('/home');
      } else {
        showError('注册失败，请稍后重试', title: '注册失败');
      }
    }, onError: (error) {
      LoggerUtil.e('注册失败: $error');
      showError('注册过程中发生错误，请稍后重试', title: '注册失败');
    });
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