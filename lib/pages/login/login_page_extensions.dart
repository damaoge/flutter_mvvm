import 'package:flutter/material.dart';

import 'package:flutter_mvvm/core/screen/screen_adapter.dart';
import 'package:flutter_mvvm/pages/login/login_viewmodel.dart';

/// 登录页面UI构建扩展方法
extension LoginPageExtensions on State {
  /// 构建登录页面头部
  Widget buildLoginHeader(BuildContext context) {
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
            Icons.flutter_dash,
            size: ScreenAdapter.setWidth(50),
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ScreenAdapter.setHeight(24)),
        
        // 标题
        Text(
          '欢迎回来',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: ScreenAdapter.setHeight(8)),
        
        // 副标题
        Text(
          '请登录您的账户',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  /// 构建登录表单
  Widget buildLoginForm(BuildContext context, LoginViewModel viewModel) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        children: [
          // 邮箱输入框
          buildEmailField(context, viewModel),
          
          SizedBox(height: ScreenAdapter.setHeight(16)),
          
          // 密码输入框
          buildPasswordField(context, viewModel),
          
          SizedBox(height: ScreenAdapter.setHeight(16)),
          
          // 记住密码
          buildRememberPasswordCheckbox(context, viewModel),
        ],
      ),
    );
  }

  /// 构建邮箱输入框
  Widget buildEmailField(BuildContext context, LoginViewModel viewModel) {
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
  Widget buildPasswordField(BuildContext context, LoginViewModel viewModel) {
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

  /// 构建记住密码复选框
  Widget buildRememberPasswordCheckbox(BuildContext context, LoginViewModel viewModel) {
    return Row(
      children: [
        Checkbox(
          value: viewModel.rememberPassword,
          onChanged: viewModel.toggleRememberPassword,
        ),
        const Text('记住密码'),
      ],
    );
  }

  /// 构建登录按钮
  Widget buildLoginButton(BuildContext context, LoginViewModel viewModel) {
    return SizedBox(
      height: ScreenAdapter.setHeight(50),
      child: ElevatedButton(
        onPressed: viewModel.isLoading ? null : viewModel.login,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(12)),
          ),
        ),
        child: viewModel.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                '登录',
                style: TextStyle(
                  fontSize: ScreenAdapter.setSp(16),
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// 构建忘记密码链接
  Widget buildForgotPasswordLink(BuildContext context, LoginViewModel viewModel) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: viewModel.forgotPassword,
        child: const Text('忘记密码？'),
      ),
    );
  }

  /// 构建注册链接
  Widget buildRegisterLink(BuildContext context, LoginViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('还没有账户？'),
        TextButton(
          onPressed: viewModel.goToRegister,
          child: const Text('立即注册'),
        ),
      ],
    );
  }

  /// 构建页面背景
  Widget buildLoginBackground(BuildContext context, Widget child) {
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