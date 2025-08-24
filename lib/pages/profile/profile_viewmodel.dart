import 'package:flutter/material.dart';

import 'package:flutter_mvvm/core/base/base_viewmodel.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'package:flutter_mvvm/core/services/user_profile_service.dart';
import 'package:flutter_mvvm/models/user_profile.dart';

/// 个人资料ViewModel
class ProfileViewModel extends BaseViewModel {
  // 服务实例
  final UserProfileService _profileService = UserProfileService.instance;

  // 用户信息
  UserProfile _userProfile = UserProfile.defaultProfile();
  UserProfile get userProfile => _userProfile;

  String get userName => _userProfile.name;
  String get userEmail => _userProfile.email;
  String get userPhone => _userProfile.maskedPhone;
  String get userAvatar => _userProfile.avatar;

  @override
  void onInit() {
    super.onInit();
    LoggerUtil.d('ProfileViewModel 初始化');
    _loadUserInfo();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    await safeExecute(() async {
      // 模拟网络请求延迟
      await Future.delayed(const Duration(milliseconds: 500));
      
      final profile = await _profileService.getUserProfile();
      if (profile != null) {
        _userProfile = profile;
        notifyListeners();
      }
    });
  }

  /// 刷新用户信息
  Future<void> refreshUserInfo() async {
    await _loadUserInfo();
  }

  /// 编辑个人资料
  void editProfile() {
    // 这里可以跳转到编辑页面
    showInfo('编辑个人资料功能待实现', title: '编辑功能');
  }

  /// 更换头像
  Future<void> changeAvatar() async {
    // 这里可以实现头像更换功能
    // 示例：假设从图片选择器获取新头像URL
    // final newAvatarUrl = await ImagePicker.pickImage();
    // if (newAvatarUrl != null) {
    //   await _profileService.updateAvatar(newAvatarUrl);
    //   await _loadUserInfo();
    // }
    
    showInfo('更换头像功能待实现', title: '更换头像');
  }

  /// 跳转到设置页面
  void goToSettings() {
    navigateTo('/settings');
  }

  /// 退出登录
  void logout() {
    showConfirmDialog(
      title: '退出登录',
      content: '确定要退出登录吗？',
      confirmText: '确定',
      cancelText: '取消',
      onConfirm: () {
        // 清除用户数据
        _profileService.clearUserData();
        // 跳转到登录页面
        navigateAndClearStack('/login');
      },
    );
  }

  /// 查看个人统计
  void viewStatistics() {
    showInfo('个人统计功能待实现', title: '个人统计');
  }

  /// 查看收藏
  void viewFavorites() {
    showInfo('收藏功能待实现', title: '我的收藏');
  }

  /// 查看历史记录
  void viewHistory() {
    showInfo('历史记录功能待实现', title: '历史记录');
  }
}