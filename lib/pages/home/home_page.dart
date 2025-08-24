import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/base/base_view.dart';
import '../../core/base/base_viewmodel.dart';
import '../../core/utils/logger_util.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/screen/screen_adapter.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/router/router_manager.dart';

/// 首页ViewModel
class HomeViewModel extends BaseViewModel {
  // 计数器
  int _counter = 0;
  int get counter => _counter;

  // 用户信息
  String _userName = '未登录';
  String get userName => _userName;

  @override
  void onInit() {
    super.onInit();
    LoggerUtil.d('HomeViewModel 初始化');
    _loadUserInfo();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      setLoading(true);
      // 模拟网络请求
      await Future.delayed(const Duration(seconds: 1));
      _userName = 'Flutter用户';
      notifyListeners();
    } catch (e) {
      LoggerUtil.e('加载用户信息失败: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 增加计数
  void incrementCounter() {
    _counter++;
    notifyListeners();
    LoggerUtil.d('计数器增加: $_counter');
  }

  /// 重置计数
  void resetCounter() {
    _counter = 0;
    notifyListeners();
    LoggerUtil.d('计数器重置');
  }

  /// 切换主题
  void toggleTheme() {
    ThemeManager.instance.toggleTheme();
  }

  /// 切换语言
  void toggleLanguage() {
    final currentLocale = LocalizationManager.instance.currentLocale;
    if (currentLocale.languageCode == 'zh') {
      LocalizationManager.instance.setLocale(const Locale('en', 'US'));
    } else {
      LocalizationManager.instance.setLocale(const Locale('zh', 'CN'));
    }
  }

  /// 跳转到设置页面
  void goToSettings() {
    RouterManager.instance.push('/settings');
  }

  /// 跳转到个人资料页面
  void goToProfile() {
    RouterManager.instance.push('/profile');
  }
}

/// 首页View
class HomePage extends BaseView<HomeViewModel> {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomeViewModel createViewModel() => HomeViewModel();

  @override
  String? get title => context.l10n.home;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: viewModel.goToSettings,
      ),
    ];
  }

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUserCard(),
          SizedBox(height: ScreenAdapter.setHeight(20)),
          _buildCounterCard(),
          SizedBox(height: ScreenAdapter.setHeight(20)),
          _buildActionButtons(),
          SizedBox(height: ScreenAdapter.setHeight(20)),
          _buildFeatureGrid(),
        ],
      ),
    );
  }

  /// 构建用户卡片
  Widget _buildUserCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: Column(
          children: [
            CircleAvatar(
              radius: ScreenAdapter.setWidth(30),
              child: Icon(
                Icons.person,
                size: ScreenAdapter.setWidth(30),
              ),
            ),
            SizedBox(height: ScreenAdapter.setHeight(12)),
            Text(
              viewModel.userName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: ScreenAdapter.setHeight(8)),
            ElevatedButton(
              onPressed: viewModel.goToProfile,
              child: Text(context.l10n.profile),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建计数器卡片
  Widget _buildCounterCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: Column(
          children: [
            Text(
              '计数器',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: ScreenAdapter.setHeight(16)),
            Text(
              '${viewModel.counter}',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ScreenAdapter.setHeight(16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: viewModel.incrementCounter,
                  child: const Text('增加'),
                ),
                OutlinedButton(
                  onPressed: viewModel.resetCounter,
                  child: const Text('重置'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '主题和语言',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: ScreenAdapter.setHeight(16)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: viewModel.toggleTheme,
                    icon: const Icon(Icons.palette),
                    label: const Text('切换主题'),
                  ),
                ),
                SizedBox(width: ScreenAdapter.setWidth(12)),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: viewModel.toggleLanguage,
                    icon: const Icon(Icons.language),
                    label: const Text('切换语言'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建功能网格
  Widget _buildFeatureGrid() {
    final features = [
      {'icon': Icons.network_check, 'title': '网络请求', 'subtitle': 'Dio封装'},
      {'icon': Icons.storage, 'title': '数据库', 'subtitle': 'SQLite/Hive'},
      {'icon': Icons.cached, 'title': '缓存管理', 'subtitle': '多级缓存'},
      {'icon': Icons.route, 'title': '路由管理', 'subtitle': 'GetX路由'},
      {'icon': Icons.security, 'title': '权限管理', 'subtitle': 'Android/iOS'},
      {'icon': Icons.phone_android, 'title': '屏幕适配', 'subtitle': '响应式布局'},
    ];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '功能特性',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: ScreenAdapter.setHeight(16)),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: ScreenAdapter.setWidth(12),
                mainAxisSpacing: ScreenAdapter.setHeight(12),
                childAspectRatio: 1.2,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        feature['icon'] as IconData,
                        size: ScreenAdapter.setWidth(32),
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(height: ScreenAdapter.setHeight(8)),
                      Text(
                        feature['title'] as String,
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ScreenAdapter.setHeight(4)),
                      Text(
                        feature['subtitle'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}