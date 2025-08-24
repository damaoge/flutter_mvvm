import 'package:flutter_mvvm/core/managers/storage_manager.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 用户资料服务
/// 负责处理用户个人信息的管理
class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  static UserProfileService get instance => _instance;

  // 存储键名
  static const String _userInfoKey = 'user_info';

  /// 获取用户信息
  Future<UserProfile> getUserProfile() async {
    try {
      final userInfo = await StorageManager.instance.getJson(_userInfoKey);
      if (userInfo != null) {
        return UserProfile.fromJson(userInfo);
      }
      return UserProfile.defaultProfile();
    } catch (e) {
      LoggerUtil.e('获取用户信息失败: $e');
      return UserProfile.defaultProfile();
    }
  }

  /// 更新用户信息
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await StorageManager.instance.setJson(_userInfoKey, profile.toJson());
      LoggerUtil.d('用户信息更新成功');
    } catch (e) {
      LoggerUtil.e('更新用户信息失败: $e');
      rethrow;
    }
  }

  /// 更新用户头像
  Future<void> updateAvatar(String avatarUrl) async {
    try {
      final profile = await getUserProfile();
      final updatedProfile = profile.copyWith(avatar: avatarUrl);
      await updateUserProfile(updatedProfile);
      LoggerUtil.d('用户头像更新成功');
    } catch (e) {
      LoggerUtil.e('更新用户头像失败: $e');
      rethrow;
    }
  }

  /// 更新用户名
  Future<void> updateName(String name) async {
    try {
      final profile = await getUserProfile();
      final updatedProfile = profile.copyWith(name: name);
      await updateUserProfile(updatedProfile);
      LoggerUtil.d('用户名更新成功');
    } catch (e) {
      LoggerUtil.e('更新用户名失败: $e');
      rethrow;
    }
  }

  /// 更新用户邮箱
  Future<void> updateEmail(String email) async {
    try {
      final profile = await getUserProfile();
      final updatedProfile = profile.copyWith(email: email);
      await updateUserProfile(updatedProfile);
      LoggerUtil.d('用户邮箱更新成功');
    } catch (e) {
      LoggerUtil.e('更新用户邮箱失败: $e');
      rethrow;
    }
  }

  /// 更新用户手机号
  Future<void> updatePhone(String phone) async {
    try {
      final profile = await getUserProfile();
      final updatedProfile = profile.copyWith(phone: phone);
      await updateUserProfile(updatedProfile);
      LoggerUtil.d('用户手机号更新成功');
    } catch (e) {
      LoggerUtil.e('更新用户手机号失败: $e');
      rethrow;
    }
  }

  /// 清除用户信息
  Future<void> clearUserProfile() async {
    try {
      await StorageManager.instance.remove(_userInfoKey);
      LoggerUtil.d('用户信息清除成功');
    } catch (e) {
      LoggerUtil.e('清除用户信息失败: $e');
      rethrow;
    }
  }

  /// 检查用户信息是否存在
  Future<bool> hasUserProfile() async {
    try {
      final userInfo = await StorageManager.instance.getJson(_userInfoKey);
      return userInfo != null;
    } catch (e) {
      LoggerUtil.e('检查用户信息失败: $e');
      return false;
    }
  }
}

/// 用户资料数据类
class UserProfile {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  /// 从JSON创建用户资料
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 创建默认用户资料
  factory UserProfile.defaultProfile() {
    return const UserProfile(
      name: 'Flutter用户',
      email: 'flutter@example.com',
      phone: '138****8888',
      avatar: '',
    );
  }

  /// 复制并修改用户资料
  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 是否有头像
  bool get hasAvatar => avatar.isNotEmpty;

  /// 是否有完整信息
  bool get hasCompleteInfo => name.isNotEmpty && email.isNotEmpty;

  /// 获取显示名称
  String get displayName => name.isNotEmpty ? name : email;

  /// 获取脱敏手机号
  String get maskedPhone {
    if (phone.isEmpty || phone.length < 11) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(7)}';
  }

  /// 获取脱敏邮箱
  String get maskedEmail {
    if (email.isEmpty || !email.contains('@')) return email;
    final parts = email.split('@');
    if (parts[0].length <= 2) return email;
    return '${parts[0].substring(0, 2)}****@${parts[1]}';
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, phone: $phone, hasAvatar: $hasAvatar)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.avatar == avatar;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        avatar.hashCode;
  }
}