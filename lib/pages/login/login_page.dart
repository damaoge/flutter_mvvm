import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/base/base_view.dart';
import '../../core/base/base_viewmodel.dart';
import '../../core/utils/logger_util.dart';
import '../../core/screen/screen_adapter.dart';
import '../../core/router/router_manager.dart';
import '../../core/storage/storage_manager.dart';
import '../../core/widgets/loading_dialog.dart';
import '../../core/network/network_manager.dart';

/// 登录页面ViewModel
class LoginViewModel extends BaseViewModel {
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
      final savedEmail = await StorageManager.instance.getString('saved_email');
      final savedPassword = await StorageManager.instance.getString('saved_password');
      final rememberPwd = await StorageManager.instance.getBool('remember_password') ?? false;
      
      if (savedEmail != null) {
        emailController.text = savedEmail;
      }
      
      if (rememberPwd && savedPassword != null) {
        passwordController.text = savedPassword;
        _rememberPassword = true;
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
      LoadingDialog.show('登录中...');

      final email = emailController.text.trim();
      final password = passwordController.text;

      // 模拟网络请求
      await Future.delayed(const Duration(seconds: 2));
      
      // 这里应该调用实际的登录API
      // final response = await NetworkManager.instance.post('/auth/login', {
      //   'email': email,
      //   'password': password,
      // });
      
      // 模拟登录成功
      final mockResponse = {
        'success': true,
        'data': {
          'token': 'mock_token_123456',
          'user': {
            'id': 1,
            'name': 'Flutter用户',
            'email': email,
            'avatar': '',
          },
        },
      };

      if (mockResponse['success'] == true) {
        // 保存登录信息
        await _saveLoginInfo(mockResponse['data'] as Map<String, dynamic>);
        
        // 保存凭据（如果选择记住密码）
        if (_rememberPassword) {
          await _saveCredentials(email, password);
        } else {
          await _clearSavedCredentials();
        }

        LoadingDialog.dismiss();
        LoadingDialog.showSuccess('登录成功');
        
        // 跳转到首页
        await Future.delayed(const Duration(milliseconds: 500));
        RouterManager.instance.pushAndClearStack('/home');
        
        LoggerUtil.d('用户登录成功: $email');
      } else {
        throw Exception('登录失败');
      }
    } catch (e) {
      LoadingDialog.dismiss();
      LoadingDialog.showError('登录失败: ${e.toString()}');
      LoggerUtil.e('登录失败: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 保存登录信息
  Future<void> _saveLoginInfo(Map<String, dynamic> data) async {
    await StorageManager.instance.setString('user_token', data['token']);
    await StorageManager.instance.setJson('user_info', data['user']);
  }

  /// 保存凭据
  Future<void> _saveCredentials(String email, String password) async {
    await StorageManager.instance.setString('saved_email', email);
    await StorageManager.instance.setString('saved_password', password);
    await StorageManager.instance.setBool('remember_password', true);
  }

  /// 清除保存的凭据
  Future<void> _clearSavedCredentials() async {
    await StorageManager.instance.remove('saved_password');
    await StorageManager.instance.setBool('remember_password', false);
  }

  /// 跳转到注册页面
  void goToRegister() {
    RouterManager.instance.push('/register');
  }

  /// 忘记密码
  void forgotPassword() {
    RouterManager.instance.showSnackbar(
      '忘记密码',
      '忘记密码功能待实现',
      SnackPosition.TOP,
    );
  }

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
    return null;
  }
}

/// 登录页面View
class LoginPage extends BaseView<LoginViewModel> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginViewModel createViewModel() => LoginViewModel();

  @override
  bool get showAppBar => false;

  @override
  Widget buildContent(BuildContext context) {
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
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ScreenAdapter.setWidth(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: ScreenAdapter.setHeight(60)),
              _buildHeader(context),
              SizedBox(height: ScreenAdapter.setHeight(40)),
              _buildLoginForm(context),
              SizedBox(height: ScreenAdapter.setHeight(24)),
              _buildLoginButton(context),
              SizedBox(height: ScreenAdapter.setHeight(16)),
              _buildForgotPassword(context),
              SizedBox(height: ScreenAdapter.setHeight(40)),
              _buildRegisterLink(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(BuildContext context) {
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
  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        children: [
          // 邮箱输入框
          TextFormField(
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
          ),
          
          SizedBox(height: ScreenAdapter.setHeight(16)),
          
          // 密码输入框
          TextFormField(
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
          ),
          
          SizedBox(height: ScreenAdapter.setHeight(16)),
          
          // 记住密码
          Row(
            children: [
              Checkbox(
                value: viewModel.rememberPassword,
                onChanged: viewModel.toggleRememberPassword,
              ),
              const Text('记住密码'),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建登录按钮
  Widget _buildLoginButton(BuildContext context) {
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

  /// 构建忘记密码
  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: viewModel.forgotPassword,
        child: const Text('忘记密码？'),
      ),
    );
  }

  /// 构建注册链接
  Widget _buildRegisterLink(BuildContext context) {
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
}