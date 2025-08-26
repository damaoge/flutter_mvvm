import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../../../core/base/base_viewmodel.dart';
import '../../../../core/router/router_manager.dart';

/// 认证ViewModel
@injectable
class AuthViewModel extends BaseViewModel {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final RouterManager _routerManager;

  AuthViewModel(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
    this._routerManager,
  );

  // 当前用户
  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;

  // 认证状态
  AuthStatus _authStatus = AuthStatus.unauthenticated;
  AuthStatus get authStatus => _authStatus;

  // 是否已登录
  bool get isLoggedIn => _authStatus == AuthStatus.authenticated && _currentUser != null;

  // 是否正在认证
  bool get isAuthenticating => _authStatus == AuthStatus.authenticating;

  // 错误信息
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  /// 检查认证状态
  Future<void> _checkAuthStatus() async {
    try {
      setLoading(true);
      _setAuthStatus(AuthStatus.authenticating);
      
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        _currentUser = user;
        _setAuthStatus(AuthStatus.authenticated);
      } else {
        _currentUser = null;
        _setAuthStatus(AuthStatus.unauthenticated);
      }
    } catch (e) {
      _currentUser = null;
      _setAuthStatus(AuthStatus.authenticationFailed);
      _setErrorMessage('检查认证状态失败: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// 用户登录
  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      setLoading(true);
      _setAuthStatus(AuthStatus.authenticating);
      _clearError();

      final params = LoginParams(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      final result = await _loginUseCase(params);

      if (result.isSuccess) {
        _currentUser = result.user;
        _setAuthStatus(AuthStatus.authenticated);
        
        // 导航到主页
        _routerManager.pushReplacementNamed('/home');
      } else {
        _setAuthStatus(AuthStatus.authenticationFailed);
        _setErrorMessage(result.message ?? '登录失败');
      }
    } catch (e) {
      _setAuthStatus(AuthStatus.authenticationFailed);
      _setErrorMessage('登录失败: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// 用户注册
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      setLoading(true);
      _setAuthStatus(AuthStatus.authenticating);
      _clearError();

      final params = RegisterParams(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      final result = await _registerUseCase(params);

      if (result.isSuccess) {
        _currentUser = result.user;
        _setAuthStatus(AuthStatus.authenticated);
        
        // 导航到主页
        _routerManager.pushReplacementNamed('/home');
      } else {
        _setAuthStatus(AuthStatus.authenticationFailed);
        _setErrorMessage(result.message ?? '注册失败');
      }
    } catch (e) {
      _setAuthStatus(AuthStatus.authenticationFailed);
      _setErrorMessage('注册失败: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// 用户登出
  Future<void> logout() async {
    try {
      setLoading(true);
      _clearError();

      final success = await _logoutUseCase();
      
      if (success) {
        _currentUser = null;
        _setAuthStatus(AuthStatus.unauthenticated);
        
        // 导航到登录页
        _routerManager.pushReplacementNamed('/login');
      } else {
        _setErrorMessage('登出失败');
      }
    } catch (e) {
      // 即使登出失败，也清除本地状态
      _currentUser = null;
      _setAuthStatus(AuthStatus.unauthenticated);
      _routerManager.pushReplacementNamed('/login');
    } finally {
      setLoading(false);
    }
  }

  /// 刷新用户信息
  Future<void> refreshUser() async {
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        _currentUser = user;
        _setAuthStatus(AuthStatus.authenticated);
      } else {
        _currentUser = null;
        _setAuthStatus(AuthStatus.unauthenticated);
      }
      notifyListeners();
    } catch (e) {
      _setErrorMessage('刷新用户信息失败: ${e.toString()}');
    }
  }

  /// 验证会话
  Future<bool> validateSession() async {
    try {
      return await _getCurrentUserUseCase.validateSession();
    } catch (e) {
      return false;
    }
  }

  /// 导航到登录页
  void navigateToLogin() {
    _routerManager.pushReplacementNamed('/login');
  }

  /// 导航到注册页
  void navigateToRegister() {
    _routerManager.pushNamed('/register');
  }

  /// 导航到主页
  void navigateToHome() {
    _routerManager.pushReplacementNamed('/home');
  }

  /// 设置认证状态
  void _setAuthStatus(AuthStatus status) {
    if (_authStatus != status) {
      _authStatus = status;
      notifyListeners();
    }
  }

  /// 设置错误信息
  void _setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// 清除错误信息
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// 清除错误（公共方法）
  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    super.dispose();
  }
}