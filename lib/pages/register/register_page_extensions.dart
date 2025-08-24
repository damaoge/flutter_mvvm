import 'package:flutter/material.dart';

import 'package:flutter_mvvm/core/screen/screen_adapter.dart';
import 'package:flutter_mvvm/pages/register/register_viewmodel.dart';

/// 注册页面UI构建扩展方法
extension RegisterPageExtensions on State {
  /// 构建注册页面头部
  Widget buildRegisterHeader(BuildContext context) {
    return Column(
      children: [
        // 应用图标
        Container(
          width: ScreenAdapter.setWidth(80),
          height: ScreenAdapter.setWidth(80),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(16)),
          ),
          child: Icon(
            Icons.person_add,
            size: ScreenAdapter.setWidth(50),
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ScreenAdapter.setHeight(24)),
        
        // 标题
        Text(
          '创建账户',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: ScreenAdapter.setHeight(8)),
        
        // 副标题
        Text(
          '请填写以下信息完成注册',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  /// 构建注册表单
  Widget buildRegisterForm(BuildContext context, RegisterViewModel viewModel) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        children: [
          // 姓名输入框
          buildNameField(context, viewModel),
          
          SizedBox(height: ScreenAdapter.setHeight(16)),
          
          // 邮箱输入框
          buildEmailField(context, viewModel),
          
          SizedBox(height: ScreenAdapter.setHeight(16)),
          
          // 密码输入框
          buildPasswordField(context, viewModel),
          
          SizedBox(height: ScreenAdapter.setHeight(16)),
          
          // 确认密码输入框
          buildConfirmPasswordField(context, viewModel),
          
          SizedBox(height: ScreenAdapter.setHeight(16)),
          
          // 同意条款复选框
          buildTermsCheckbox(context, viewModel),
        ],
      ),
    );
  }

  /// 构建姓名输入框
  Widget buildNameField(BuildContext context, RegisterViewModel viewModel) {
    return TextFormField(
      controller: viewModel.nameController,
      validator: viewModel.validateName,
      decoration: InputDecoration(
        labelText: '姓名',
        hintText: '请输入您的姓名',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(12)),
        ),
      ),
    );
  }

  /// 构建邮箱输入框
  Widget buildEmailField(BuildContext context, RegisterViewModel viewModel) {
    return TextFormField(
      controller: viewModel.emailController,
      keyboardType: TextInputType.emailAddress,
      validator: viewModel.validateEmail,
      decoration: InputDecoration(
        labelText: '邮箱',
        hintText: '请输入邮箱地址',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(12)),
        ),
      ),
    );
  }

  /// 构建密码输入框
  Widget buildPasswordField(BuildContext context, RegisterViewModel viewModel) {
    return TextFormField(
      controller: viewModel.passwordController,
      obscureText: !viewModel.isPasswordVisible,
      validator: viewModel.validatePassword,
      decoration: InputDecoration(
        labelText: '密码',
        hintText: '请输入密码',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.isPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: viewModel.togglePasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(12)),
        ),
      ),
    );
  }

  /// 构建确认密码输入框
  Widget buildConfirmPasswordField(BuildContext context, RegisterViewModel viewModel) {
    return TextFormField(
      controller: viewModel.confirmPasswordController,
      obscureText: !viewModel.isConfirmPasswordVisible,
      validator: viewModel.validateConfirmPassword,
      decoration: InputDecoration(
        labelText: '确认密码',
        hintText: '请再次输入密码',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.isConfirmPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: viewModel.toggleConfirmPasswordVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(12)),
        ),
      ),
    );
  }

  /// 构建同意条款复选框
  Widget buildTermsCheckbox(BuildContext context, RegisterViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: viewModel.agreeToTerms,
          onChanged: viewModel.toggleAgreeToTerms,
        ),
        Expanded(
          child: Wrap(
            children: [
              const Text('我已阅读并同意'),
              GestureDetector(
                onTap: viewModel.viewTermsOfService,
                child: Text(
                  '《用户协议》',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text('和'),
              GestureDetector(
                onTap: viewModel.viewPrivacyPolicy,
                child: Text(
                  '《隐私政策》',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建注册按钮
  Widget buildRegisterButton(BuildContext context, RegisterViewModel viewModel) {
    return SizedBox(
      height: ScreenAdapter.setHeight(50),
      child: ElevatedButton(
        onPressed: viewModel.isLoading ? null : viewModel.register,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(12)),
          ),
        ),
        child: viewModel.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                '注册',
                style: TextStyle(
                  fontSize: ScreenAdapter.setSp(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// 构建登录链接
  Widget buildLoginLink(BuildContext context, RegisterViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('已有账户？'),
        TextButton(
          onPressed: viewModel.goToLogin,
          child: const Text('立即登录'),
        ),
      ],
    );
  }

  /// 构建页面背景
  Widget buildRegisterBackground(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: child,
    );
  }
}