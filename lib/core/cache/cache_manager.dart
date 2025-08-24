import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../base/app_config.dart';
import '../utils/logger_util.dart';
import '../database/database_manager.dart';

/// 缓存管理器
/// 提供内存缓存和持久化缓存功能
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  static CacheManager get instance => _instance;
  
  // 内存缓存
  final Map<String, CacheItem> _memoryCache = {};
  
  // Hive缓存盒子
  Box<String>? _cacheBox;
  
  CacheManager._internal();
  
  /// 初始化缓存管理器
  Future<void> init() async {
    try {
      // 初始化Hive缓存
      _cacheBox = await Hive.openBox<String>('cache_box');
      
      // 清理过期的内存缓存
      _cleanExpiredMemoryCache();
      
      // 清理过期的持久化缓存
      await _cleanExpiredPersistentCache();
      
      LoggerUtil.i('缓存管理器初始化完成');
    } catch (e) {
      LoggerUtil.e('缓存管理器初始化失败: $e');
      rethrow;
    }
  }
  
  /// 设置内存缓存
  void setMemoryCache(
    String key,
    dynamic value, {
    Duration? expiration,
  }) {
    try {
      final expireTime = expiration != null
          ? DateTime.now().add(expiration)
          : null;
      
      _memoryCache[key] = CacheItem(
        value: value,
        expireTime: expireTime,
        createdAt: DateTime.now(),
      );
      
      LoggerUtil.cache('SET_MEMORY', key, value: value);
    } catch (e) {
      LoggerUtil.e('设置内存缓存失败: $key, error: $e');
    }
  }
  
  /// 获取内存缓存
  T? getMemoryCache<T>(String key) {
    try {
      final item = _memoryCache[key];
      if (item == null) {
        LoggerUtil.cache('GET_MEMORY', key, value: 'NOT_FOUND');
        return null;
      }
      
      if (item.isExpired) {
        _memoryCache.remove(key);
        LoggerUtil.cache('GET_MEMORY', key, value: 'EXPIRED');
        return null;
      }
      
      LoggerUtil.cache('GET_MEMORY', key, value: item.value);
      return item.value as T?;
    } catch (e) {
      LoggerUtil.e('获取内存缓存失败: $key, error: $e');
      return null;
    }
  }
  
  /// 删除内存缓存
  void removeMemoryCache(String key) {
    try {
      _memoryCache.remove(key);
      LoggerUtil.cache('REMOVE_MEMORY', key);
    } catch (e) {
      LoggerUtil.e('删除内存缓存失败: $key, error: $e');
    }
  }
  
  /// 清空内存缓存
  void clearMemoryCache() {
    try {
      _memoryCache.clear();
      LoggerUtil.cache('CLEAR_MEMORY', 'ALL');
    } catch (e) {
      LoggerUtil.e('清空内存缓存失败: $e');
    }
  }
  
  /// 设置持久化缓存（Hive）
  Future<void> setPersistentCache(
    String key,
    dynamic value, {
    Duration? expiration,
  }) async {
    try {
      if (_cacheBox == null) {
        throw Exception('缓存盒子未初始化');
      }
      
      final cacheData = {
        'value': value,
        'expireTime': expiration != null
            ? DateTime.now().add(expiration).millisecondsSinceEpoch
            : null,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };
      
      await _cacheBox!.put(key, jsonEncode(cacheData));
      LoggerUtil.cache('SET_PERSISTENT', key, value: value);
    } catch (e) {
      LoggerUtil.e('设置持久化缓存失败: $key, error: $e');
    }
  }
  
  /// 获取持久化缓存（Hive）
  Future<T?> getPersistentCache<T>(String key) async {
    try {
      if (_cacheBox == null) {
        throw Exception('缓存盒子未初始化');
      }
      
      final cacheDataString = _cacheBox!.get(key);
      if (cacheDataString == null) {
        LoggerUtil.cache('GET_PERSISTENT', key, value: 'NOT_FOUND');
        return null;
      }
      
      final cacheData = jsonDecode(cacheDataString) as Map<String, dynamic>;
      final expireTime = cacheData['expireTime'] as int?;
      
      if (expireTime != null && DateTime.now().millisecondsSinceEpoch > expireTime) {
        await _cacheBox!.delete(key);
        LoggerUtil.cache('GET_PERSISTENT', key, value: 'EXPIRED');
        return null;
      }
      
      final value = cacheData['value'];
      LoggerUtil.cache('GET_PERSISTENT', key, value: value);
      return value as T?;
    } catch (e) {
      LoggerUtil.e('获取持久化缓存失败: $key, error: $e');
      return null;
    }
  }
  
  /// 删除持久化缓存
  Future<void> removePersistentCache(String key) async {
    try {
      if (_cacheBox == null) {
        throw Exception('缓存盒子未初始化');
      }
      
      await _cacheBox!.delete(key);
      LoggerUtil.cache('REMOVE_PERSISTENT', key);
    } catch (e) {
      LoggerUtil.e('删除持久化缓存失败: $key, error: $e');
    }
  }
  
  /// 清空持久化缓存
  Future<void> clearPersistentCache() async {
    try {
      if (_cacheBox == null) {
        throw Exception('缓存盒子未初始化');
      }
      
      await _cacheBox!.clear();
      LoggerUtil.cache('CLEAR_PERSISTENT', 'ALL');
    } catch (e) {
      LoggerUtil.e('清空持久化缓存失败: $e');
    }
  }
  
  /// 设置数据库缓存
  Future<void> setDatabaseCache(
    String key,
    dynamic value, {
    Duration? expiration,
  }) async {
    try {
      final expireTime = expiration != null
          ? DateTime.now().add(expiration).millisecondsSinceEpoch
          : DateTime.now().add(Duration(milliseconds: AppConfig.cacheExpireTime)).millisecondsSinceEpoch;
      
      await DatabaseManager.instance.insert('cache', {
        'key': key,
        'value': jsonEncode(value),
        'expire_time': expireTime,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      
      LoggerUtil.cache('SET_DATABASE', key, value: value);
    } catch (e) {
      LoggerUtil.e('设置数据库缓存失败: $key, error: $e');
    }
  }
  
  /// 获取数据库缓存
  Future<T?> getDatabaseCache<T>(String key) async {
    try {
      final result = await DatabaseManager.instance.query(
        'cache',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      
      if (result.isEmpty) {
        LoggerUtil.cache('GET_DATABASE', key, value: 'NOT_FOUND');
        return null;
      }
      
      final cacheData = result.first;
      final expireTime = cacheData['expire_time'] as int;
      
      if (DateTime.now().millisecondsSinceEpoch > expireTime) {
        await DatabaseManager.instance.delete(
          'cache',
          where: 'key = ?',
          whereArgs: [key],
        );
        LoggerUtil.cache('GET_DATABASE', key, value: 'EXPIRED');
        return null;
      }
      
      final value = jsonDecode(cacheData['value'] as String);
      LoggerUtil.cache('GET_DATABASE', key, value: value);
      return value as T?;
    } catch (e) {
      LoggerUtil.e('获取数据库缓存失败: $key, error: $e');
      return null;
    }
  }
  
  /// 删除数据库缓存
  Future<void> removeDatabaseCache(String key) async {
    try {
      await DatabaseManager.instance.delete(
        'cache',
        where: 'key = ?',
        whereArgs: [key],
      );
      LoggerUtil.cache('REMOVE_DATABASE', key);
    } catch (e) {
      LoggerUtil.e('删除数据库缓存失败: $key, error: $e');
    }
  }
  
  /// 清空数据库缓存
  Future<void> clearDatabaseCache() async {
    try {
      await DatabaseManager.instance.delete('cache');
      LoggerUtil.cache('CLEAR_DATABASE', 'ALL');
    } catch (e) {
      LoggerUtil.e('清空数据库缓存失败: $e');
    }
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
  
  /// 清理过期的内存缓存
  void _cleanExpiredMemoryCache() {
    final expiredKeys = <String>[];
    _memoryCache.forEach((key, item) {
      if (item.isExpired) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      _memoryCache.remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      LoggerUtil.d('清理过期内存缓存: ${expiredKeys.length}个');
    }
  }
  
  /// 清理过期的持久化缓存
  Future<void> _cleanExpiredPersistentCache() async {
    try {
      if (_cacheBox == null) return;
      
      final expiredKeys = <String>[];
      final now = DateTime.now().millisecondsSinceEpoch;
      
      for (final key in _cacheBox!.keys) {
        final cacheDataString = _cacheBox!.get(key);
        if (cacheDataString != null) {
          try {
            final cacheData = jsonDecode(cacheDataString) as Map<String, dynamic>;
            final expireTime = cacheData['expireTime'] as int?;
            if (expireTime != null && now > expireTime) {
              expiredKeys.add(key as String);
            }
          } catch (e) {
            // 数据格式错误，也删除
            expiredKeys.add(key as String);
          }
        }
      }
      
      for (final key in expiredKeys) {
        await _cacheBox!.delete(key);
      }
      
      if (expiredKeys.isNotEmpty) {
        LoggerUtil.d('清理过期持久化缓存: ${expiredKeys.length}个');
      }
    } catch (e) {
      LoggerUtil.e('清理过期持久化缓存失败: $e');
    }
  }
  
  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStats() {
    return {
      'memoryCache': {
        'count': _memoryCache.length,
        'keys': _memoryCache.keys.toList(),
      },
      'persistentCache': {
        'count': _cacheBox?.length ?? 0,
        'keys': _cacheBox?.keys.toList() ?? [],
      },
    };
  }
}

/// 缓存项
class CacheItem {
  final dynamic value;
  final DateTime? expireTime;
  final DateTime createdAt;
  
  CacheItem({
    required this.value,
    this.expireTime,
    required this.createdAt,
  });
  
  bool get isExpired {
    if (expireTime == null) return false;
    return DateTime.now().isAfter(expireTime!);
  }
}

/// 缓存类型
enum CacheType {
  /// 内存缓存（最快，但应用重启后丢失）
  memory,
  
  /// 持久化缓存（Hive，快速且持久）
  persistent,
  
  /// 数据库缓存（SQLite，可查询但较慢）
  database,
}