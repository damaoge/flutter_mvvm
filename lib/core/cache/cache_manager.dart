import 'memory_cache_manager.dart';
import 'persistent_cache_manager.dart';
import 'database_cache_manager.dart';
import 'cache_types.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'package:flutter_mvvm/core/patterns/cache_factory.dart';

/// 统一缓存管理器
/// 提供统一的缓存接口，整合内存缓存、持久化缓存和数据库缓存
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  static CacheManager get instance => _instance;
  
  // 各类型缓存管理器
  late final MemoryCacheManager _memoryCache;
  late final PersistentCacheManager _persistentCache;
  late final DatabaseCacheManager _databaseCache;
  
  CacheManager._internal() {
    _memoryCache = MemoryCacheManager.instance;
    _persistentCache = PersistentCacheManager.instance;
    _databaseCache = DatabaseCacheManager.instance;
  }
  
  /// 使用工厂模式获取缓存管理器
  ICacheManager getCacheManagerByType(CacheType type) {
    return CacheFactory.getCacheManager(type);
  }
  
  /// 智能选择缓存管理器
  ICacheManager getSmartCacheManager({
    required int dataSize,
    required bool needsPersistence,
    required bool frequentAccess,
    required bool needsQuery,
  }) {
    return CacheFactory.getRecommendedCacheManager(
      dataSize: dataSize,
      needsPersistence: needsPersistence,
      frequentAccess: frequentAccess,
      needsQuery: needsQuery,
    );
  }
  
  /// 初始化缓存管理器
  Future<void> init() async {
    try {
      // 初始化持久化缓存
      await _persistentCache.init();
      
      // 清理过期缓存
      await cleanAllExpired();
      
      LoggerUtil.i('统一缓存管理器初始化完成');
    } catch (e) {
      LoggerUtil.e('统一缓存管理器初始化失败: $e');
      rethrow;
    }
  }
  
  // 内存缓存相关方法
  void setMemoryCache(String key, dynamic value, {Duration? expiration}) {
    _memoryCache.set(key, value, expiration: expiration);
  }
  
  T? getMemoryCache<T>(String key) {
    return _memoryCache.get<T>(key);
  }
  
  void removeMemoryCache(String key) {
    _memoryCache.remove(key);
  }
  
  void clearMemoryCache() {
    _memoryCache.clear();
  }
  
  // 持久化缓存相关方法
  Future<void> setPersistentCache(String key, dynamic value, {Duration? expiration}) async {
    await _persistentCache.set(key, value, expiration: expiration);
  }
  
  Future<T?> getPersistentCache<T>(String key) async {
    return await _persistentCache.get<T>(key);
  }
  
  Future<void> removePersistentCache(String key) async {
    await _persistentCache.remove(key);
  }
  
  Future<void> clearPersistentCache() async {
    await _persistentCache.clear();
  }
  
  // 数据库缓存相关方法
  Future<void> setDatabaseCache(String key, dynamic value, {Duration? expiration}) async {
    await _databaseCache.set(key, value, expiration: expiration);
  }
  
  Future<T?> getDatabaseCache<T>(String key) async {
    return await _databaseCache.get<T>(key);
  }
  
  Future<void> removeDatabaseCache(String key) async {
    await _databaseCache.remove(key);
  }
  
  Future<void> clearDatabaseCache() async {
    await _databaseCache.clear();
  }
  
  /// 统一缓存接口 - 设置
  Future<void> set(
    String key,
    dynamic value, {
    Duration? expiration,
    CacheType type = CacheType.memory,
  }) async {
    switch (type) {
      case CacheType.memory:
        setMemoryCache(key, value, expiration: expiration);
        break;
      case CacheType.persistent:
        await setPersistentCache(key, value, expiration: expiration);
        break;
      case CacheType.database:
        await setDatabaseCache(key, value, expiration: expiration);
        break;
    }
  }
  
  /// 统一缓存接口 - 获取
  Future<T?> get<T>(
    String key, {
    CacheType type = CacheType.memory,
  }) async {
    switch (type) {
      case CacheType.memory:
        return getMemoryCache<T>(key);
      case CacheType.persistent:
        return await getPersistentCache<T>(key);
      case CacheType.database:
        return await getDatabaseCache<T>(key);
    }
  }
  
  /// 统一缓存接口 - 删除
  Future<void> remove(
    String key, {
    CacheType type = CacheType.memory,
  }) async {
    switch (type) {
      case CacheType.memory:
        removeMemoryCache(key);
        break;
      case CacheType.persistent:
        await removePersistentCache(key);
        break;
      case CacheType.database:
        await removeDatabaseCache(key);
        break;
    }
  }
  
  /// 统一缓存接口 - 清空
  Future<void> clear({CacheType type = CacheType.memory}) async {
    switch (type) {
      case CacheType.memory:
        clearMemoryCache();
        break;
      case CacheType.persistent:
        await clearPersistentCache();
        break;
      case CacheType.database:
        await clearDatabaseCache();
        break;
    }
  }
  
  /// 清理所有类型的过期缓存
  Future<void> cleanAllExpired() async {
    try {
      _memoryCache.cleanExpired();
      await _persistentCache.cleanExpired();
      await _databaseCache.cleanExpired();
      LoggerUtil.i('所有缓存过期清理完成');
    } catch (e) {
      LoggerUtil.e('清理过期缓存失败: $e');
    }
  }
  
  /// 清理指定类型的过期缓存
  Future<void> cleanExpired(CacheType type) async {
    try {
      switch (type) {
        case CacheType.memory:
          _memoryCache.cleanExpired();
          break;
        case CacheType.persistent:
          await _persistentCache.cleanExpired();
          break;
        case CacheType.database:
          await _databaseCache.cleanExpired();
          break;
      }
    } catch (e) {
      LoggerUtil.e('清理${type.name}过期缓存失败: $e');
    }
  }
  
  /// 检查缓存是否存在
  Future<bool> contains(String key, {CacheType type = CacheType.memory}) async {
    final cacheManager = getCacheManagerByType(type);
    return await cacheManager.contains(key);
  }
  
  /// 智能缓存操作
  Future<void> setSmartCache(
    String key, 
    dynamic value, {
    Duration? expiration,
    required int dataSize,
    required bool needsPersistence,
    required bool frequentAccess,
    required bool needsQuery,
  }) async {
    final cacheManager = getSmartCacheManager(
      dataSize: dataSize,
      needsPersistence: needsPersistence,
      frequentAccess: frequentAccess,
      needsQuery: needsQuery,
    );
    
    await cacheManager.set(key, value, expiration: expiration);
    
    final selectedType = CacheFactory.selectOptimalCacheType(
      dataSize: dataSize,
      needsPersistence: needsPersistence,
      frequentAccess: frequentAccess,
      needsQuery: needsQuery,
    );
    
    LoggerUtil.i('智能缓存已设置: $key -> ${selectedType.name}');
  }
  
  /// 智能获取缓存
  Future<T?> getSmartCache<T>(
    String key, {
    required int expectedDataSize,
    required bool needsPersistence,
    required bool frequentAccess,
    required bool needsQuery,
  }) async {
    final cacheManager = getSmartCacheManager(
      dataSize: expectedDataSize,
      needsPersistence: needsPersistence,
      frequentAccess: frequentAccess,
      needsQuery: needsQuery,
    );
    
    return await cacheManager.get<T>(key);
  }
  
  /// 获取缓存管理器实例
  MemoryCacheManager get memoryCache => _memoryCache;
  PersistentCacheManager get persistentCache => _persistentCache;
  DatabaseCacheManager get databaseCache => _databaseCache;
  
  /// 获取综合缓存统计信息
  Future<Map<String, dynamic>> getCacheStats() async {
    final memoryStats = _memoryCache.getStats();
    final persistentStats = _persistentCache.getStats();
    final databaseStats = await _databaseCache.getStats();
    
    return {
      'memory': memoryStats,
      'persistent': persistentStats,
      'database': databaseStats,
      'total': {
        'count': memoryStats['count'] + persistentStats['count'] + databaseStats['count'],
      },
    };
  }
  
  /// 关闭缓存管理器
  Future<void> close() async {
    try {
      await _persistentCache.close();
      LoggerUtil.i('统一缓存管理器已关闭');
    } catch (e) {
      LoggerUtil.e('关闭统一缓存管理器失败: $e');
    }
  }
}