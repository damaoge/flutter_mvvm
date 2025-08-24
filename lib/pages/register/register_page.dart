import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/base/base_view.dart';
import '../../core/base/base_viewmodel.dart';
import '../../core/utils/logger_util.dart';
import '../../core/screen/screen_adapter.dart';
import '../../core/router/router_manager.dart';
import '../../core/storage/storage_manager.dart';
import '../../core/widgets/loading_dialog.dart';

/// 注册页面ViewModel
class RegisterViewModel extends BaseViewModel {
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
      LoadingDialog.showError('请先同意用户协议和隐私政策');
      return;
    }

    try {
      setLoading(true);
      LoadingDialog.show('注册中...');

      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;

      // 模拟网络请求
      await Future.delayed(const Duration(seconds: 2));
      
      // 这里应该调用实际的注册API
      // final response = await NetworkManager.instance.post('/auth/register', {
      //   'name': name,
      //   'email': email,
      //   'password': password,
      // });
      
      // 模拟注册成功
      final mockResponse = {
        'success': true,
        'data': {
          'token': 'mock_token_123456',
          'user': {
            'id': 1,
            'name': name,
            'email': email,
            'avatar': '',
          },
        },
      };

      if (mockResponse['success'] == true) {
        // 保存注册信息
        await _saveRegisterInfo(mockResponse['data'] as Map<String, dynamic>);

        LoadingDialog.dismiss();
        LoadingDialog.showSuccess('注册成功');
        
        // 跳转到首页
        await Future.delayed(const Duration(milliseconds: 500));
        RouterManager.instance.pushAndClearStack('/home');
        
        LoggerUtil.d('用户注册成功: $email');
      } else {
        throw Exception('注册失败');
      }
    } catch (e) {
      LoadingDialog.dismiss();
      LoadingDialog.showError('注册失败: ${e.toString()}');
      LoggerUtil.e('注册失败: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 保存注册信息
  Future<void> _saveRegisterInfo(Map<String, dynamic> data) async {
    await StorageManager.instance.setString('user_token', data['token']);
    await StorageManager.instance.setJson('user_info', data['user']);
  }

  /// 跳转到登录页面
  void goToLogin() {
    RouterManager.instance.pop();
  }

  /// 查看用户协议
  void showUserAgreement() {
    RouterManager.instance.showSnackbar(
      '用户协议',
      '用户协议功能待实现',
      SnackPosition.TOP,
    );
  }

  /// 查看隐私政策
  void showPrivacyPolicy() {
    RouterManager.instance.showSnackbar(
      '隐私政策',
      '隐私政策功能待实现',
      SnackPosition.TOP,
    );
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

  /// 确认密码验证
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != passwordController.text) {
      return '两次输入的密码不一致';
    }
    return null;
  }
}

/// 注册页面View
class RegisterPage extends BaseView<RegisterViewModel> {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  RegisterViewModel createViewModel() => RegisterViewModel();

  @override
  String? get title => '注册账户';

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ScreenAdapter.setWidth(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: ScreenAdapter.setHeight(20)),
          _buildHeader(context),
          SizedBox(height: ScreenAdapter.setHeight(32)),
          _buildRegisterForm(context),
          SizedBox(height: ScreenAdapter.setHeight(24)),
          _buildTermsAgreement(context),
          SizedBox(height: ScreenAdapter.setHeight(24)),
          _buildRegisterButton(context),
          SizedBox(height: ScreenAdapter.setHeight(32)),
          _buildLoginLink(context),
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // 标题
        Text(
          '创建新账户',
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
  Widget _buildRegisterForm(BuildContext context) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        children: [
          // 用户名输入框
          TextFormField(
            controller: viewModel.nameController,
            validator: viewModel.validateName,
            decoration: InputDecoration(
              labelText: '用户名',
              hintText: '请输入用户名',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(12)),
              ),
            ),
          ),
          
          SizedBox(height: ScreenAdapter.setHeight(16)),
          
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
              hintText: '请输入密码（6-20位）',
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
          
          // 确认密码输入框
          TextFormField(
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
          ),
        ],
      ),
    );
  }

  /// 构建条款同意
  Widget _buildTermsAgreement(BuildContext context) {
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
                onTap: viewModel.showUserAgreement,
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
                onTap: viewModel.showPrivacyPolicy,
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
  Widget _buildRegisterButton(BuildContext context) {
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
  Widget _buildLoginLink(BuildContext context) {
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
}