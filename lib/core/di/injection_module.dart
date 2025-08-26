import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_mvvm/core/datasource/base_datasource.dart';
import 'package:flutter_mvvm/core/datasource/remote_datasource.dart';
import 'package:flutter_mvvm/core/datasource/local_datasource.dart';
import 'package:flutter_mvvm/core/storage/storage_manager.dart';
import 'package:flutter_mvvm/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_mvvm/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_mvvm/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_mvvm/features/auth/domain/repositories/auth_repository.dart';

/// 依赖注入模块
/// 用于注册第三方库和复杂的依赖关系
@module
abstract class InjectionModule {
  /// 注册SharedPreferences实例
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();
  
  /// 注册Dio实例
  @lazySingleton
  Dio get dio => Dio();
  
  /// 注册应用配置
  @lazySingleton
  @Named('baseUrl')
  String get baseUrl => 'https://api.example.com';
  
  @lazySingleton
  @Named('connectTimeout')
  int get connectTimeout => 30000;
  
  @lazySingleton
  @Named('receiveTimeout')
  int get receiveTimeout => 30000;
  
  /// 注册远程数据源
  @lazySingleton
  RemoteDataSource remoteDataSource(Dio dio) => RemoteDataSourceImpl(dio);
  
  /// 注册本地数据源
  @lazySingleton
  LocalDataSource localDataSource(IStorageManager storageManager) => LocalDataSourceImpl(storageManager);
  
  /// 注册认证远程数据源
  @lazySingleton
  IAuthRemoteDataSource authRemoteDataSource(RemoteDataSource remoteDataSource) => AuthRemoteDataSource(remoteDataSource);
  
  /// 注册认证本地数据源
  @lazySingleton
  IAuthLocalDataSource authLocalDataSource(LocalDataSource localDataSource) => AuthLocalDataSource(localDataSource);
  
  /// 注册认证仓储
  @lazySingleton
  IAuthRepository authRepository(
    IAuthRemoteDataSource remoteDataSource,
    IAuthLocalDataSource localDataSource,
  ) => AuthRepositoryImpl(remoteDataSource, localDataSource);
}