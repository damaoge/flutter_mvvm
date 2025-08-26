import 'package:injectable/injectable.dart';
import '../datasource/base_datasource.dart';
import '../services/auth_service.dart';
import 'base_repository.dart';

/// 用户数据模型
class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}

/// 用户Repository接口
abstract class IUserRepository extends BaseRepository<User, int> {
  Future<User?> login(String email, String password);
  Future<User?> register(String name, String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
}

/// 用户Repository实现
@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository {
  final IAuthService _authService;
  
  UserRepository(this._authService);
  
  @override
  Future<User?> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      if (response['success'] == true) {
        final userData = response['data']['user'] as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      throw DataSourceException('登录失败: $e');
    }
  }
  
  @override
  Future<User?> register(String name, String email, String password) async {
    try {
      final response = await _authService.register(name, email, password);
      if (response['success'] == true) {
        final userData = response['data']['user'] as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      throw DataSourceException('注册失败: $e');
    }
  }
  
  @override
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      throw DataSourceException('登出失败: $e');
    }
  }
  
  @override
  Future<User?> getCurrentUser() async {
    try {
      final userData = await _authService.getCurrentUser();
      if (userData != null) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      throw DataSourceException('获取用户信息失败: $e');
    }
  }
  
  @override
  Future<bool> isLoggedIn() async {
    try {
      return await _authService.isLoggedIn();
    } catch (e) {
      return false;
    }
  }
  
  // 实现BaseRepository的抽象方法
  @override
  Future<User?> getById(int id) async {
    // 这里可以实现从API获取用户信息的逻辑
    throw UnimplementedError('getById not implemented');
  }
  
  @override
  Future<List<User>> getAll() async {
    throw UnimplementedError('getAll not implemented');
  }
  
  @override
  Future<List<User>> getPage(int page, int size) async {
    throw UnimplementedError('getPage not implemented');
  }
  
  @override
  Future<User> create(User entity) async {
    throw UnimplementedError('create not implemented');
  }
  
  @override
  Future<User> update(User entity) async {
    throw UnimplementedError('update not implemented');
  }
  
  @override
  Future<void> delete(int id) async {
    throw UnimplementedError('delete not implemented');
  }
  
  @override
  Future<void> deleteAll(List<int> ids) async {
    throw UnimplementedError('deleteAll not implemented');
  }
  
  @override
  Future<bool> exists(int id) async {
    throw UnimplementedError('exists not implemented');
  }
  
  @override
  Future<int> count() async {
    throw UnimplementedError('count not implemented');
  }
  
  @override
  Future<void> clear() async {
    throw UnimplementedError('clear not implemented');
  }
}