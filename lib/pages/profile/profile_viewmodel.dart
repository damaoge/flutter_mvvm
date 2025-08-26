import 'package:flutter/material.dart';

import 'package:flutter_mvvm/core/base/base_viewmodel.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'package:flutter_mvvm/core/repository/user_repository.dart';
import 'package:flutter_mvvm/models/user_profile.dart';
import 'package:flutter_mvvm/core/di/service_locator.dart';

/// 个人资料ViewModel
class ProfileViewModel extends BaseViewModel {
  // Repository实例
  final IUserRepository _userRepository = getIt<IUserRepository>();

  // 用户信息
  UserProfile _userProfile = UserProfile.defaultProfile();
  UserProfile get userProfile => _userProfile;
  
  // 当前用户
  User? _currentUser;
  User? get currentUser => _currentUser;

  String get userName => _currentUser?.name ?? _userProfile.name;
  String get userEmail => _currentUser?.email ?? _userProfile.email;
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
      LoggerUtil.d('加载用户信息');
      
      // 检查是否已登录
      final isLoggedIn = await _userRepository.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _userRepository.getCurrentUser();
        if (_currentUser != null) {
          // 如果有用户信息，更新UserProfile
          _userProfile = UserProfile(
            id: _currentUser!.id,
            name: _currentUser!.name,
            email: _currentUser!.email,
            phone: '', // 这里可以从用户扩展信息获取
            avatar: '', // 这里可以从用户扩展信息获取
            bio: '',
            location: '',
            website: '',
            joinDate: _currentUser!.createdAt,
          );
        }
      }
      
      notifyListeners();
      LoggerUtil.d('用户信息加载完成: ${userName}');
    }, onError: (error) {
      LoggerUtil.e('加载用户信息失败: $error');
      showError('加载用户信息失败，请稍后重试', title: '加载失败');
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
      onConfirm: () async {
        await safeExecute(() async {
          LoggerUtil.d('用户退出登录');
          
          // 调用用户Repository退出登录
          await _userRepository.logout();
          
          // 清空当前用户信息
          _currentUser = null;
          _userProfile = UserProfile.defaultProfile();
          
          showSuccess('已退出登录', title: '退出成功');
          
          // 跳转到登录页面
          navigateAndClearStack('/login');
        }, onError: (error) {
          LoggerUtil.e('退出登录失败: $error');
          showError('退出登录失败，请稍后重试', title: '退出失败');
        });
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