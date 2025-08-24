import 'package:get/get.dart';

/// 表单验证服务
/// 负责处理各种表单字段的验证逻辑
class ValidationService {
  static final ValidationService _instance = ValidationService._internal();
  factory ValidationService() => _instance;
  ValidationService._internal();

  static ValidationService get instance => _instance;

  /// 邮箱验证
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入邮箱';
    }
    if (!GetUtils.isEmail(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  /// 密码验证
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码长度不能少于6位';
    }
    if (value.length > 20) {
      return '密码长度不能超过20位';
    }
    return null;
  }

  /// 用户名验证
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入用户名';
    }
    if (value.length < 2) {
      return '用户名长度不能少于2位';
    }
    if (value.length > 20) {
      return '用户名长度不能超过20位';
    }
    return null;
  }

  /// 确认密码验证
  String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != password) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  /// 手机号验证
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return '请输入有效的手机号';
    }
    return null;
  }

  /// 验证码验证
  String? validateVerificationCode(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入验证码';
    }
    if (value.length != 6) {
      return '验证码长度应为6位';
    }
    if (!GetUtils.isNumericOnly(value)) {
      return '验证码只能包含数字';
    }
    return null;
  }

  /// 昵称验证
  String? validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入昵称';
    }
    if (value.length < 1) {
      return '昵称不能为空';
    }
    if (value.length > 15) {
      return '昵称长度不能超过15位';
    }
    return null;
  }

  /// 身份证号验证
  String? validateIdCard(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入身份证号';
    }
    
    // 简单的身份证号格式验证
    final idCardRegex = RegExp(r'^[1-9]\d{5}(18|19|20)\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$');
    if (!idCardRegex.hasMatch(value)) {
      return '请输入有效的身份证号';
    }
    return null;
  }

  /// 银行卡号验证
  String? validateBankCard(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入银行卡号';
    }
    if (value.length < 16 || value.length > 19) {
      return '银行卡号长度应为16-19位';
    }
    if (!GetUtils.isNumericOnly(value)) {
      return '银行卡号只能包含数字';
    }
    return null;
  }

  /// 金额验证
  String? validateAmount(String? value, {double? minAmount, double? maxAmount}) {
    if (value == null || value.isEmpty) {
      return '请输入金额';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return '请输入有效的金额';
    }
    
    if (amount <= 0) {
      return '金额必须大于0';
    }
    
    if (minAmount != null && amount < minAmount) {
      return '金额不能小于$minAmount';
    }
    
    if (maxAmount != null && amount > maxAmount) {
      return '金额不能大于$maxAmount';
    }
    
    return null;
  }

  /// 通用非空验证
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '请输入$fieldName';
    }
    return null;
  }

  /// 通用长度验证
  String? validateLength(String? value, String fieldName, {int? minLength, int? maxLength}) {
    if (value == null || value.isEmpty) {
      return '请输入$fieldName';
    }
    
    if (minLength != null && value.length < minLength) {
      return '$fieldName长度不能少于${minLength}位';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return '$fieldName长度不能超过${maxLength}位';
    }
    
    return null;
  }
}