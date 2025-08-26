import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// 用户模型类
@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// 从JSON创建UserModel实例
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// 创建副本
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
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
    return 'UserModel(id: $id, name: $name, email: $email, avatar: $avatar, phone: $phone, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// 认证响应模型
@JsonSerializable()
class AuthResponseModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => _$AuthResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);

  AuthResponseModel copyWith({
    UserModel? user,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) {
    return AuthResponseModel(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthResponseModel &&
        other.user == user &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.expiresAt == expiresAt;
  }

  @override
  int get hashCode {
    return Object.hash(user, accessToken, refreshToken, expiresAt);
  }

  @override
  String toString() {
    return 'AuthResponseModel(user: $user, accessToken: $accessToken, refreshToken: $refreshToken, expiresAt: $expiresAt)';
  }
}

/// 登录请求模型
@JsonSerializable()
class LoginRequestModel {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequestModel({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) => _$LoginRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginRequestModel &&
        other.email == email &&
        other.password == password &&
        other.rememberMe == rememberMe;
  }

  @override
  int get hashCode => Object.hash(email, password, rememberMe);

  @override
  String toString() {
    return 'LoginRequestModel(email: $email, password: [HIDDEN], rememberMe: $rememberMe)';
  }
}

/// 注册请求模型
@JsonSerializable()
class RegisterRequestModel {
  final String name;
  final String email;
  final String password;
  final String? phone;

  const RegisterRequestModel({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) => _$RegisterRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegisterRequestModel &&
        other.name == name &&
        other.email == email &&
        other.password == password &&
        other.phone == phone;
  }

  @override
  int get hashCode => Object.hash(name, email, password, phone);

  @override
  String toString() {
    return 'RegisterRequestModel(name: $name, email: $email, password: [HIDDEN], phone: $phone)';
  }
}