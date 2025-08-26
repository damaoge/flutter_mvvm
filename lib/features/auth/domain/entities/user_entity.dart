/// 用户实体类 - 领域层
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// 创建副本
  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 获取显示名称
  String get displayName => name.isNotEmpty ? name : email;

  /// 获取头像URL或默认头像
  String get avatarUrl => avatar ?? _getDefaultAvatar();

  /// 检查是否有头像
  bool get hasAvatar => avatar != null && avatar!.isNotEmpty;

  /// 检查是否有电话号码
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  /// 获取用户的初始字母（用于默认头像）
  String get initials {
    if (name.isEmpty) return email.isNotEmpty ? email[0].toUpperCase() : '?';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : '?';
    }
    
    return (words[0].isNotEmpty ? words[0][0] : '') +
           (words[1].isNotEmpty ? words[1][0] : '');
  }

  /// 检查用户是否为新用户（注册时间小于7天）
  bool get isNewUser {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays < 7;
  }

  /// 获取账户年龄（天数）
  int get accountAgeDays {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  /// 检查用户信息是否完整
  bool get isProfileComplete {
    return name.isNotEmpty && 
           email.isNotEmpty && 
           hasAvatar && 
           hasPhone;
  }

  /// 获取完整度百分比
  double get profileCompleteness {
    int completedFields = 0;
    int totalFields = 4; // name, email, avatar, phone
    
    if (name.isNotEmpty) completedFields++;
    if (email.isNotEmpty) completedFields++;
    if (hasAvatar) completedFields++;
    if (hasPhone) completedFields++;
    
    return completedFields / totalFields;
  }

  /// 获取默认头像URL
  String _getDefaultAvatar() {
    // 使用用户名或邮箱生成默认头像
    final seed = name.isNotEmpty ? name : email;
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(seed)}&background=random';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.avatar == avatar &&
        other.phone == phone &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      email,
      avatar,
      phone,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserEntity(id: $id, name: $name, email: $email, avatar: $avatar, phone: $phone, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// 认证状态枚举
enum AuthStatus {
  /// 未认证
  unauthenticated,
  /// 已认证
  authenticated,
  /// 认证中
  authenticating,
  /// 认证失败
  authenticationFailed,
  /// 令牌过期
  tokenExpired,
}

/// 认证结果实体
class AuthResultEntity {
  final UserEntity? user;
  final AuthStatus status;
  final String? message;
  final String? errorCode;

  const AuthResultEntity({
    this.user,
    required this.status,
    this.message,
    this.errorCode,
  });

  /// 认证成功
  bool get isSuccess => status == AuthStatus.authenticated && user != null;

  /// 认证失败
  bool get isFailure => status == AuthStatus.authenticationFailed;

  /// 正在认证
  bool get isLoading => status == AuthStatus.authenticating;

  /// 令牌过期
  bool get isTokenExpired => status == AuthStatus.tokenExpired;

  /// 创建成功结果
  factory AuthResultEntity.success(UserEntity user) {
    return AuthResultEntity(
      user: user,
      status: AuthStatus.authenticated,
      message: '认证成功',
    );
  }

  /// 创建失败结果
  factory AuthResultEntity.failure(String message, [String? errorCode]) {
    return AuthResultEntity(
      status: AuthStatus.authenticationFailed,
      message: message,
      errorCode: errorCode,
    );
  }

  /// 创建加载中结果
  factory AuthResultEntity.loading() {
    return const AuthResultEntity(
      status: AuthStatus.authenticating,
      message: '正在认证...',
    );
  }

  /// 创建令牌过期结果
  factory AuthResultEntity.tokenExpired() {
    return const AuthResultEntity(
      status: AuthStatus.tokenExpired,
      message: '登录已过期，请重新登录',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResultEntity &&
        other.user == user &&
        other.status == status &&
        other.message == message &&
        other.errorCode == errorCode;
  }

  @override
  int get hashCode {
    return Object.hash(user, status, message, errorCode);
  }

  @override
  String toString() {
    return 'AuthResultEntity(user: $user, status: $status, message: $message, errorCode: $errorCode)';
  }
}