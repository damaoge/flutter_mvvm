import 'package:flutter/material.dart';
import 'package:flutter_mvvm/core/base/base_view.dart';
import 'package:flutter_mvvm/core/base/base_viewmodel.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'package:flutter_mvvm/core/screen/screen_adapter.dart';
import 'package:flutter_mvvm/core/repository/user_repository.dart';
import 'package:flutter_mvvm/core/di/service_locator.dart';
import 'package:flutter_mvvm/core/base/app_config.dart';

/// 启动页ViewModel
class SplashViewModel extends BaseViewModel {
  final IUserRepository _userRepository = getIt<IUserRepository>();
  
  @override
  void onInit() {
    super.onInit();
    LoggerUtil.d('SplashViewModel 初始化');
    _initializeApp();
  }

  /// 初始化应用
  Future<void> _initializeApp() async {
    await safeExecute(() async {
      // 模拟初始化过程
      await Future.delayed(const Duration(seconds: 2));
      
      // 检查登录状态
      final isLoggedIn = await _checkLoginStatus();
      
      // 跳转到相应页面
      if (isLoggedIn) {
        navigateAndClearStack('/home');
      } else {
        navigateAndClearStack('/home'); // 暂时直接跳转到首页
      }
    }, onError: (error) {
      LoggerUtil.e('应用初始化失败: $error');
      // 即使初始化失败也跳转到首页
      navigateAndClearStack('/home');
    });
  }

  /// 检查登录状态
  Future<bool> _checkLoginStatus() async {
    try {
      return await _userRepository.isLoggedIn();
    } catch (e) {
      LoggerUtil.e('检查登录状态失败: $e');
      return false;
    }
  }
}

/// 启动页View
class SplashPage extends BaseView<SplashViewModel> {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashViewModel createViewModel() => SplashViewModel();

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
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 应用图标
            Container(
              width: ScreenAdapter.setWidth(120),
              height: ScreenAdapter.setWidth(120),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.flutter_dash,
                size: ScreenAdapter.setWidth(80),
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            SizedBox(height: ScreenAdapter.setHeight(30)),
            
            // 应用名称
            Text(
              AppConfig.appName,
              style: TextStyle(
                fontSize: ScreenAdapter.setSp(32),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: ScreenAdapter.setHeight(10)),
            
            // 应用版本
            Text(
              'v${AppConfig.version}',
              style: TextStyle(
                fontSize: ScreenAdapter.setSp(16),
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            
            SizedBox(height: ScreenAdapter.setHeight(60)),
            
            // 加载指示器
            if (viewModel.isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}