import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/base/base_view.dart';
import '../../core/base/base_viewmodel.dart';
import '../../core/utils/logger_util.dart';
import '../../core/router/router_manager.dart';
import '../../core/screen/screen_adapter.dart';
import '../../core/base/app_config.dart';

/// 启动页ViewModel
class SplashViewModel extends BaseViewModel {
  @override
  void onInit() {
    super.onInit();
    LoggerUtil.d('SplashViewModel 初始化');
    _initializeApp();
  }

  /// 初始化应用
  Future<void> _initializeApp() async {
    try {
      setLoading(true);
      
      // 模拟初始化过程
      await Future.delayed(const Duration(seconds: 2));
      
      // 检查登录状态
      final isLoggedIn = await _checkLoginStatus();
      
      // 跳转到相应页面
      if (isLoggedIn) {
        RouterManager.instance.pushAndClearStack('/home');
      } else {
        RouterManager.instance.pushAndClearStack('/home'); // 暂时直接跳转到首页
      }
    } catch (e) {
      LoggerUtil.e('应用初始化失败: $e');
      // 即使初始化失败也跳转到首页
      RouterManager.instance.pushAndClearStack('/home');
    } finally {
      setLoading(false);
    }
  }

  /// 检查登录状态
  Future<bool> _checkLoginStatus() async {
    // 这里可以检查本地存储的登录信息
    // 暂时返回false
    return false;
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