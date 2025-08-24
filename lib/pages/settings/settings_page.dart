import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/base/base_view.dart';
import '../../core/base/base_viewmodel.dart';
import '../../core/utils/logger_util.dart';
import '../../core/localization/localization_manager.dart';
import '../../core/screen/screen_adapter.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/router/router_manager.dart';
import '../../core/storage/storage_manager.dart';
import '../../core/cache/cache_manager.dart';
import '../../core/widgets/loading_dialog.dart';

/// 设置页ViewModel
class SettingsViewModel extends BaseViewModel {
  // 当前主题模式
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // 当前语言
  Locale _currentLocale = const Locale('zh', 'CN');
  Locale get currentLocale => _currentLocale;

  // 缓存大小
  String _cacheSize = '0 MB';
  String get cacheSize => _cacheSize;

  @override
  void onInit() {
    super.onInit();
    LoggerUtil.d('SettingsViewModel 初始化');
    _loadSettings();
  }

  /// 加载设置信息
  Future<void> _loadSettings() async {
    try {
      setLoading(true);
      
      // 获取当前主题模式
      _themeMode = ThemeManager.instance.themeMode;
      
      // 获取当前语言
      _currentLocale = LocalizationManager.instance.currentLocale;
      
      // 计算缓存大小
      await _calculateCacheSize();
      
      notifyListeners();
    } catch (e) {
      LoggerUtil.e('加载设置信息失败: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 计算缓存大小
  Future<void> _calculateCacheSize() async {
    try {
      // 这里可以实现实际的缓存大小计算
      // 暂时使用模拟数据
      _cacheSize = '12.5 MB';
    } catch (e) {
      LoggerUtil.e('计算缓存大小失败: $e');
      _cacheSize = '0 MB';
    }
  }

  /// 切换主题模式
  Future<void> changeThemeMode(ThemeMode mode) async {
    try {
      await ThemeManager.instance.setThemeMode(mode);
      _themeMode = mode;
      notifyListeners();
      LoggerUtil.d('主题模式已切换: $mode');
    } catch (e) {
      LoggerUtil.e('切换主题模式失败: $e');
    }
  }

  /// 切换语言
  Future<void> changeLanguage(Locale locale) async {
    try {
      await LocalizationManager.instance.setLocale(locale);
      _currentLocale = locale;
      notifyListeners();
      LoggerUtil.d('语言已切换: ${locale.languageCode}');
    } catch (e) {
      LoggerUtil.e('切换语言失败: $e');
    }
  }

  /// 清除缓存
  Future<void> clearCache() async {
    try {
      LoadingDialog.show('清除缓存中...');
      
      // 清除内存缓存
      await CacheManager.instance.clearMemoryCache();
      
      // 清除持久化缓存
      await CacheManager.instance.clearPersistentCache();
      
      // 清除数据库缓存
      await CacheManager.instance.clearDatabaseCache();
      
      // 重新计算缓存大小
      await _calculateCacheSize();
      
      notifyListeners();
      
      LoadingDialog.dismiss();
      LoadingDialog.showSuccess('缓存清除成功');
      
      LoggerUtil.d('缓存已清除');
    } catch (e) {
      LoadingDialog.dismiss();
      LoadingDialog.showError('缓存清除失败');
      LoggerUtil.e('清除缓存失败: $e');
    }
  }

  /// 关于应用
  void showAbout() {
    RouterManager.instance.push('/about');
  }

  /// 退出登录
  Future<void> logout() async {
    try {
      LoadingDialog.show('退出登录中...');
      
      // 清除用户数据
      await StorageManager.instance.remove('user_token');
      await StorageManager.instance.remove('user_info');
      
      LoadingDialog.dismiss();
      
      // 跳转到登录页
      RouterManager.instance.pushAndClearStack('/login');
      
      LoggerUtil.d('用户已退出登录');
    } catch (e) {
      LoadingDialog.dismiss();
      LoadingDialog.showError('退出登录失败');
      LoggerUtil.e('退出登录失败: $e');
    }
  }
}

/// 设置页View
class SettingsPage extends BaseView<SettingsViewModel> {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsViewModel createViewModel() => SettingsViewModel();

  @override
  String? get title => '设置';

  @override
  Widget buildContent(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
      children: [
        _buildThemeSection(context),
        SizedBox(height: ScreenAdapter.setHeight(16)),
        _buildLanguageSection(context),
        SizedBox(height: ScreenAdapter.setHeight(16)),
        _buildCacheSection(context),
        SizedBox(height: ScreenAdapter.setHeight(16)),
        _buildAboutSection(context),
        SizedBox(height: ScreenAdapter.setHeight(16)),
        _buildLogoutSection(context),
      ],
    );
  }

  /// 构建主题设置区域
  Widget _buildThemeSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '主题设置',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: ScreenAdapter.setHeight(12)),
            _buildThemeOption(context, ThemeMode.system, '跟随系统', Icons.brightness_auto),
            _buildThemeOption(context, ThemeMode.light, '浅色主题', Icons.brightness_high),
            _buildThemeOption(context, ThemeMode.dark, '深色主题', Icons.brightness_2),
          ],
        ),
      ),
    );
  }

  /// 构建主题选项
  Widget _buildThemeOption(BuildContext context, ThemeMode mode, String title, IconData icon) {
    return RadioListTile<ThemeMode>(
      value: mode,
      groupValue: viewModel.themeMode,
      onChanged: (value) {
        if (value != null) {
          viewModel.changeThemeMode(value);
        }
      },
      title: Row(
        children: [
          Icon(icon, size: ScreenAdapter.setWidth(20)),
          SizedBox(width: ScreenAdapter.setWidth(8)),
          Text(title),
        ],
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  /// 构建语言设置区域
  Widget _buildLanguageSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '语言设置',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: ScreenAdapter.setHeight(12)),
            _buildLanguageOption(context, const Locale('zh', 'CN'), '简体中文'),
            _buildLanguageOption(context, const Locale('en', 'US'), 'English'),
            _buildLanguageOption(context, const Locale('ja', 'JP'), '日本語'),
            _buildLanguageOption(context, const Locale('ko', 'KR'), '한국어'),
          ],
        ),
      ),
    );
  }

  /// 构建语言选项
  Widget _buildLanguageOption(BuildContext context, Locale locale, String title) {
    return RadioListTile<Locale>(
      value: locale,
      groupValue: viewModel.currentLocale,
      onChanged: (value) {
        if (value != null) {
          viewModel.changeLanguage(value);
        }
      },
      title: Text(title),
      contentPadding: EdgeInsets.zero,
    );
  }

  /// 构建缓存设置区域
  Widget _buildCacheSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '缓存管理',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: ScreenAdapter.setHeight(12)),
            ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('缓存大小'),
              subtitle: Text(viewModel.cacheSize),
              trailing: ElevatedButton(
                onPressed: viewModel.clearCache,
                child: const Text('清除'),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建关于区域
  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '关于',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: ScreenAdapter.setHeight(12)),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('关于应用'),
              trailing: const Icon(Icons.chevron_right),
              onTap: viewModel.showAbout,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建退出登录区域
  Widget _buildLogoutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.logout),
            label: const Text('退出登录'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// 显示退出登录确认对话框
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              viewModel.logout();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}