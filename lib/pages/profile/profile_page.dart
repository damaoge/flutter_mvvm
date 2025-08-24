import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/base/base_view.dart';
import '../../core/base/base_viewmodel.dart';
import '../../core/utils/logger_util.dart';
import '../../core/screen/screen_adapter.dart';
import '../../core/router/router_manager.dart';
import '../../core/storage/storage_manager.dart';

/// 个人资料ViewModel
class ProfileViewModel extends BaseViewModel {
  // 用户信息
  String _userName = 'Flutter用户';
  String get userName => _userName;

  String _userEmail = 'flutter@example.com';
  String get userEmail => _userEmail;

  String _userPhone = '138****8888';
  String get userPhone => _userPhone;

  String _userAvatar = '';
  String get userAvatar => _userAvatar;

  @override
  void onInit() {
    super.onInit();
    LoggerUtil.d('ProfileViewModel 初始化');
    _loadUserInfo();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      setLoading(true);
      
      // 从本地存储加载用户信息
      final userInfo = await StorageManager.instance.getJson('user_info');
      if (userInfo != null) {
        _userName = userInfo['name'] ?? _userName;
        _userEmail = userInfo['email'] ?? _userEmail;
        _userPhone = userInfo['phone'] ?? _userPhone;
        _userAvatar = userInfo['avatar'] ?? _userAvatar;
      }
      
      notifyListeners();
    } catch (e) {
      LoggerUtil.e('加载用户信息失败: $e');
    } finally {
      setLoading(false);
    }
  }

  /// 编辑个人资料
  void editProfile() {
    // 这里可以跳转到编辑页面
    RouterManager.instance.showSnackbar(
      '编辑功能',
      '编辑个人资料功能待实现',
      SnackPosition.TOP,
    );
  }

  /// 更换头像
  void changeAvatar() {
    // 这里可以实现头像更换功能
    RouterManager.instance.showSnackbar(
      '更换头像',
      '更换头像功能待实现',
      SnackPosition.TOP,
    );
  }

  /// 跳转到设置页面
  void goToSettings() {
    RouterManager.instance.push('/settings');
  }
}

/// 个人资料View
class ProfilePage extends BaseView<ProfileViewModel> {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ProfileViewModel createViewModel() => ProfileViewModel();

  @override
  String? get title => '个人资料';

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
        children: [
          _buildUserHeader(context),
          SizedBox(height: ScreenAdapter.setHeight(24)),
          _buildUserInfo(context),
          SizedBox(height: ScreenAdapter.setHeight(24)),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  /// 构建用户头部信息
  Widget _buildUserHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(24)),
        child: Column(
          children: [
            // 头像
            GestureDetector(
              onTap: viewModel.changeAvatar,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: ScreenAdapter.setWidth(50),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    backgroundImage: viewModel.userAvatar.isNotEmpty
                        ? NetworkImage(viewModel.userAvatar)
                        : null,
                    child: viewModel.userAvatar.isEmpty
                        ? Icon(
                            Icons.person,
                            size: ScreenAdapter.setWidth(50),
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(ScreenAdapter.setWidth(4)),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: ScreenAdapter.setWidth(16),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: ScreenAdapter.setHeight(16)),
            
            // 用户名
            Text(
              viewModel.userName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: ScreenAdapter.setHeight(8)),
            
            // 邮箱
            Text(
              viewModel.userEmail,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建用户信息
  Widget _buildUserInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '个人信息',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: ScreenAdapter.setHeight(16)),
            _buildInfoItem(context, '用户名', viewModel.userName, Icons.person),
            _buildInfoItem(context, '邮箱', viewModel.userEmail, Icons.email),
            _buildInfoItem(context, '手机号', viewModel.userPhone, Icons.phone),
          ],
        ),
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    return Padding(
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
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '操作',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: ScreenAdapter.setHeight(16)),
            ElevatedButton.icon(
              onPressed: viewModel.editProfile,
              icon: const Icon(Icons.edit),
              label: const Text('编辑个人资料'),
            ),
            SizedBox(height: ScreenAdapter.setHeight(12)),
            OutlinedButton.icon(
              onPressed: viewModel.goToSettings,
              icon: const Icon(Icons.settings),
              label: const Text('设置'),
            ),
          ],
        ),
      ),
    );
  }
}