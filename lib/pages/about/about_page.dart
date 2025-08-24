import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/base/base_view.dart';
import '../../core/base/base_viewmodel.dart';
import '../../core/base/app_config.dart';
import '../../core/utils/logger_util.dart';
import '../../core/screen/screen_adapter.dart';
import '../../core/router/router_manager.dart';

/// 关于页面ViewModel
class AboutViewModel extends BaseViewModel {
  @override
  void onInit() {
    super.onInit();
    LoggerUtil.d('AboutViewModel 初始化');
  }

  /// 复制版本信息
  void copyVersion() {
    Clipboard.setData(ClipboardData(text: AppConfig.version));
    RouterManager.instance.showSnackbar(
      '复制成功',
      '版本号已复制到剪贴板',
      SnackPosition.TOP,
    );
  }

  /// 复制包名
  void copyPackageName() {
    Clipboard.setData(ClipboardData(text: AppConfig.packageName));
    RouterManager.instance.showSnackbar(
      '复制成功',
      '包名已复制到剪贴板',
      SnackPosition.TOP,
    );
  }

  /// 检查更新
  void checkUpdate() {
    RouterManager.instance.showSnackbar(
      '检查更新',
      '当前已是最新版本',
      SnackPosition.TOP,
    );
  }

  /// 用户协议
  void showUserAgreement() {
    RouterManager.instance.showSnackbar(
      '用户协议',
      '用户协议功能待实现',
      SnackPosition.TOP,
    );
  }

  /// 隐私政策
  void showPrivacyPolicy() {
    RouterManager.instance.showSnackbar(
      '隐私政策',
      '隐私政策功能待实现',
      SnackPosition.TOP,
    );
  }
}

/// 关于页面View
class AboutPage extends BaseView<AboutViewModel> {
  const AboutPage({Key? key}) : super(key: key);

  @override
  AboutViewModel createViewModel() => AboutViewModel();

  @override
  String? get title => '关于';

  @override
  Widget buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
      child: Column(
        children: [
          _buildAppInfo(context),
          SizedBox(height: ScreenAdapter.setHeight(24)),
          _buildVersionInfo(context),
          SizedBox(height: ScreenAdapter.setHeight(24)),
          _buildLegalInfo(context),
          SizedBox(height: ScreenAdapter.setHeight(24)),
          _buildCopyright(context),
        ],
      ),
    );
  }

  /// 构建应用信息
  Widget _buildAppInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(24)),
        child: Column(
          children: [
            // 应用图标
            Container(
              width: ScreenAdapter.setWidth(80),
              height: ScreenAdapter.setWidth(80),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(16)),
              ),
              child: Icon(
                Icons.flutter_dash,
                size: ScreenAdapter.setWidth(50),
                color: Theme.of(context).primaryColor,
              ),
            ),
            
            SizedBox(height: ScreenAdapter.setHeight(16)),
            
            // 应用名称
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: ScreenAdapter.setHeight(8)),
            
            // 应用描述
            Text(
              '基于Flutter MVVM架构的示例应用',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建版本信息
  Widget _buildVersionInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '版本信息',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: ScreenAdapter.setHeight(16)),
            _buildInfoItem(
              context,
              '版本号',
              AppConfig.version,
              Icons.info,
              onTap: viewModel.copyVersion,
            ),
            _buildInfoItem(
              context,
              '构建号',
              AppConfig.buildNumber,
              Icons.build,
            ),
            _buildInfoItem(
              context,
              '包名',
              AppConfig.packageName,
              Icons.apps,
              onTap: viewModel.copyPackageName,
            ),
            SizedBox(height: ScreenAdapter.setHeight(16)),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: viewModel.checkUpdate,
                icon: const Icon(Icons.system_update),
                label: const Text('检查更新'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建法律信息
  Widget _buildLegalInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '法律信息',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: ScreenAdapter.setHeight(16)),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('用户协议'),
              trailing: const Icon(Icons.chevron_right),
              onTap: viewModel.showUserAgreement,
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('隐私政策'),
              trailing: const Icon(Icons.chevron_right),
              onTap: viewModel.showPrivacyPolicy,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建版权信息
  Widget _buildCopyright(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: Column(
          children: [
            Text(
              '© 2024 Flutter MVVM',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            SizedBox(height: ScreenAdapter.setHeight(8)),
            Text(
              'Powered by Flutter',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ScreenAdapter.setHeight(8)),
        child: Row(
          children: [
            Icon(
              icon,
              size: ScreenAdapter.setWidth(20),
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(width: ScreenAdapter.setWidth(12)),
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.copy,
                size: ScreenAdapter.setWidth(16),
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
          ],
        ),
      ),
    );
  }
}