import 'package:flutter/material.dart';

import 'package:flutter_mvvm/core/screen/screen_adapter.dart';
import 'package:flutter_mvvm/pages/profile/profile_viewmodel.dart';

/// 个人资料页面扩展方法
extension ProfilePageExtensions on Widget {
  /// 构建用户头像区域
  Widget buildUserAvatarSection(BuildContext context, ProfileViewModel viewModel) {
    return Container(
      padding: EdgeInsets.all(ScreenAdapter.setWidth(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ScreenAdapter.setWidth(24)),
          bottomRight: Radius.circular(ScreenAdapter.setWidth(24)),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: ScreenAdapter.setHeight(20)),
          
          // 头像
          GestureDetector(
            onTap: viewModel.changeAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: ScreenAdapter.setWidth(50),
                  backgroundImage: viewModel.userAvatar.isNotEmpty
                      ? NetworkImage(viewModel.userAvatar)
                      : null,
                  child: viewModel.userAvatar.isEmpty
                      ? Icon(
                          Icons.person,
                          size: ScreenAdapter.setWidth(50),
                          color: Colors.white,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(ScreenAdapter.setWidth(4)),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: ScreenAdapter.setWidth(16),
                      color: Theme.of(context).primaryColor,
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
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: ScreenAdapter.setHeight(8)),
          
          // 邮箱
          Text(
            viewModel.userEmail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建用户信息卡片
  Widget buildUserInfoCard(BuildContext context, ProfileViewModel viewModel) {
    return Card(
      margin: EdgeInsets.all(ScreenAdapter.setWidth(16)),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本信息',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: ScreenAdapter.setHeight(16)),
            
            _buildInfoRow(
              context,
              Icons.person,
              '用户名',
              viewModel.userName,
            ),
            
            SizedBox(height: ScreenAdapter.setHeight(12)),
            
            _buildInfoRow(
              context,
              Icons.email,
              '邮箱',
              viewModel.userEmail,
            ),
            
            SizedBox(height: ScreenAdapter.setHeight(12)),
            
            _buildInfoRow(
              context,
              Icons.phone,
              '手机号',
              viewModel.userPhone,
            ),
            
            SizedBox(height: ScreenAdapter.setHeight(16)),
            
            // 编辑按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: viewModel.editProfile,
                icon: const Icon(Icons.edit),
                label: const Text('编辑资料'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: ScreenAdapter.setHeight(12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(8)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建功能菜单
  Widget buildFunctionMenu(BuildContext context, ProfileViewModel viewModel) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.setWidth(16),
        vertical: ScreenAdapter.setHeight(8),
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(12)),
      ),
      child: Column(
        children: [
          _buildMenuTile(
            context,
            Icons.bar_chart,
            '个人统计',
            '查看使用数据和统计信息',
            viewModel.viewStatistics,
          ),
          const Divider(height: 1),
          _buildMenuTile(
            context,
            Icons.favorite,
            '我的收藏',
            '查看收藏的内容',
            viewModel.viewFavorites,
          ),
          const Divider(height: 1),
          _buildMenuTile(
            context,
            Icons.history,
            '历史记录',
            '查看浏览历史',
            viewModel.viewHistory,
          ),
          const Divider(height: 1),
          _buildMenuTile(
            context,
            Icons.settings,
            '设置',
            '应用设置和偏好',
            viewModel.goToSettings,
          ),
        ],
      ),
    );
  }

  /// 构建退出登录按钮
  Widget buildLogoutButton(BuildContext context, ProfileViewModel viewModel) {
    return Container(
      margin: EdgeInsets.all(ScreenAdapter.setWidth(16)),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: viewModel.logout,
        icon: const Icon(Icons.logout),
        label: const Text('退出登录'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: ScreenAdapter.setHeight(16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(12)),
          ),
        ),
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: ScreenAdapter.setWidth(20),
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(width: ScreenAdapter.setWidth(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建菜单项
  Widget _buildMenuTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(ScreenAdapter.setWidth(8)),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ScreenAdapter.setWidth(8)),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: ScreenAdapter.setWidth(20),
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}