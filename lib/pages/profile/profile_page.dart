import 'package:flutter/material.dart';

import 'package:flutter_mvvm/core/base/base_view.dart';
import 'package:flutter_mvvm/core/screen/screen_adapter.dart';
import 'package:flutter_mvvm/pages/profile/profile_viewmodel.dart';
import 'package:flutter_mvvm/pages/profile/profile_page_extensions.dart';

/// 个人资料页面
class ProfilePage extends BaseView<ProfileViewModel> {
  const ProfilePage({super.key});

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
    return RefreshIndicator(
      onRefresh: viewModel.refreshUserInfo,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // 用户头像区域
            buildUserAvatarSection(context, viewModel),
            
            SizedBox(height: ScreenAdapter.setHeight(16)),
            
            // 用户信息卡片
            buildUserInfoCard(context, viewModel),
            
            SizedBox(height: ScreenAdapter.setHeight(8)),
            
            // 功能菜单
            buildFunctionMenu(context, viewModel),
            
            SizedBox(height: ScreenAdapter.setHeight(16)),
            
            // 退出登录按钮
            buildLogoutButton(context, viewModel),
            
            SizedBox(height: ScreenAdapter.setHeight(32)),
          ],
        ),
      ),
    );
  }
}