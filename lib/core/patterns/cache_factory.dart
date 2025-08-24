import 'package:flutter_mvvm/core/cache/cache_types.dart';
import 'package:flutter_mvvm/core/cache/memory_cache_manager.dart';
import 'package:flutter_mvvm/core/cache/persistent_cache_manager.dart';
import 'package:flutter_mvvm/core/cache/database_cache_manager.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 缓存管理器接口
abstract class ICacheManager {
  /// 设置缓存
  Future<void> set(String key, dynamic value, {Duration? expiration});
  
  /// 获取缓存
  Future<T?> get<T>(String key);
  
  /// 移除缓存
  Future<void> remove(String key);
  
  /// 清空所有缓存
  Future<void> clear();
  
  /// 检查缓存是否存在
  Future<bool> contains(String key);
  
  /// 获取缓存统计信息
  Map<String, dynamic> getStats();
  
  /// 清理过期缓存
  Future<void> cleanExpired();
}

/// 内存缓存适配器
class MemoryCacheAdapter implements ICacheManager {
  final MemoryCacheManager _manager;
  
  MemoryCacheAdapter(this._manager);
  
  @override
  Future<void> set(String key, dynamic value, {Duration? expiration}) async {
    _manager.set(key, value, expiration: expiration);
  }
  
  @override
  Future<T?> get<T>(String key) async {
    return _manager.get<T>(key);
  }
  
  @override
  Future<void> remove(String key) async {
    _manager.remove(key);
  }
  
  @override
  Future<void> clear() async {
    _manager.clear();
  }
  
  @override
  Future<bool> contains(String key) async {
    return _manager.contains(key);
  }
  
  @override
  Map<String, dynamic> getStats() {
    return _manager.getStats();
  }
  
  @override
  Future<void> cleanExpired() async {
    _manager.cleanExpired();
  }
}

/// 持久化缓存适配器
class PersistentCacheAdapter implements ICacheManager {
  final PersistentCacheManager _manager;
  
  PersistentCacheAdapter(this._manager);
  
  @override
  Future<void> set(String key, dynamic value, {Duration? expiration}) async {
    await _manager.set(key, value, expiration: expiration);
  }
  
  @override
  Future<T?> get<T>(String key) async {
    return await _manager.get<T>(key);
  }
  
  @override
  Future<void> remove(String key) async {
    await _manager.remove(key);
  }
  
  @override
  Future<void> clear() async {
    await _manager.clear();
  }
  
  @override
  Future<bool> contains(String key) async {
    return await _manager.contains(key);
  }
  
  @override
  Map<String, dynamic> getStats() {
    return _manager.getStats();
  }
  
  @override
  Future<void> cleanExpired() async {
    await _manager.cleanExpired();
  }
}

/// 数据库缓存适配器
class DatabaseCacheAdapter implements ICacheManager {
  final DatabaseCacheManager _manager;
  
  DatabaseCacheAdapter(this._manager);
  
  @override
  Future<void> set(String key, dynamic value, {Duration? expiration}) async {
    await _manager.set(key, value, expiration: expiration);
  }
  
  @override
  Future<T?> get<T>(String key) async {
    return await _manager.get<T>(key);
  }
  
  @override
  Future<void> remove(String key) async {
    await _manager.remove(key);
  }
  
  @override
  Future<void> clear() async {
    await _manager.clear();
  }
  
  @override
  Future<bool> contains(String key) async {
    return await _manager.contains(key);
  }
  
  @override
  Map<String, dynamic> getStats() {
    return _manager.getStats();
  }
  
  @override
  Future<void> cleanExpired() async {
    await _manager.cleanExpired();
  }
}

/// 缓存工厂
class CacheFactory {
  static final Map<CacheType, ICacheManager> _cacheInstances = {};
  
  /// 获取缓存管理器实例
  static ICacheManager getCacheManager(CacheType type) {
    if (_cacheInstances.containsKey(type)) {
      return _cacheInstances[type]!;
    }
    
    ICacheManager manager;
    switch (type) {
      case CacheType.memory:
        manager = MemoryCacheAdapter(MemoryCacheManager.instance);
        break;
      case CacheType.persistent:
        manager = PersistentCacheAdapter(PersistentCacheManager.instance);
        break;
      case CacheType.database:
        manager = DatabaseCacheAdapter(DatabaseCacheManager.instance);
        break;
    }
    
    _cacheInstances[type] = manager;
    LoggerUtil.i('创建${type.name}管理器实例');
    return manager;
  }
  
  /// 根据数据特征自动选择缓存类型
  static CacheType selectOptimalCacheType({
    required int dataSize,
    required bool needsPersistence,
    required bool frequentAccess,
    required bool needsQuery,
  }) {
    // 需要查询功能，使用数据库缓存
    if (needsQuery) {
      return CacheType.database;
    }
    
    // 不需要持久化，使用内存缓存
    if (!needsPersistence) {
      return CacheType.memory;
    }
    
    // 数据量大且不频繁访问，使用数据库缓存
    if (dataSize > 1024 * 1024 && !frequentAccess) { // 1MB
      return CacheType.database;
    }
    
    // 其他情况使用持久化缓存
    return CacheType.persistent;
  }
  
  /// 获取推荐的缓存管理器
  static ICacheManager getRecommendedCacheManager({
    required int dataSize,
    required bool needsPersistence,
    required bool frequentAccess,
    required bool needsQuery,
  }) {
    final optimalType = selectOptimalCacheType(
      dataSize: dataSize,
      needsPersistence: needsPersistence,
      frequentAccess: frequentAccess,
      needsQuery: needsQuery,
    );
    
    LoggerUtil.i('为数据选择${optimalType.name}，数据大小: ${dataSize}B, 需要持久化: $needsPersistence, 频繁访问: $frequentAccess, 需要查询: $needsQuery');
    return getCacheManager(optimalType);
  }
  
  /// 清理所有缓存实例
  static Future<void> clearAllCaches() async {
    for (final manager in _cacheInstances.values) {
      await manager.clear();
    }
    LoggerUtil.i('已清理所有缓存实例');
  }
  
  /// 获取所有缓存统计信息
  static Map<CacheType, Map<String, dynamic>> getAllCacheStats() {
    final stats = <CacheType, Map<String, dynamic>>{};
    for (final entry in _cacheInstances.entries) {
      stats[entry.key] = entry.value.getStats();
    }
    return stats;
  }
}

/// 缓存策略配置
class CacheStrategyConfig {
  final CacheType primaryCache;
  final CacheType? fallbackCache;
  final Duration? defaultExpiration;
  final int maxRetries;
  
  const CacheStrategyConfig({
    required this.primaryCache,
    this.fallbackCache,
    this.defaultExpiration,
    this.maxRetries = 3,
  });
  
  /// 预定义配置
  static const CacheStrategyConfig fastAccess = CacheStrategyConfig(
    primaryCache: CacheType.memory,
    fallbackCache: CacheType.persistent,
    defaultExpiration: Duration(minutes: 30),
  );
  
  static const CacheStrategyConfig persistent = CacheStrategyConfig(
    primaryCache: CacheType.persistent,
    fallbackCache: CacheType.database,
    defaultExpiration: Duration(hours: 24),
  );
  
  static const CacheStrategyConfig queryable = CacheStrategyConfig(
    primaryCache: CacheType.database,
    defaultExpiration: Duration(days: 7),
  );
}