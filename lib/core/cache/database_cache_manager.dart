import 'dart:convert';
import 'package:flutter_mvvm/core/base/app_config.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'package:flutter_mvvm/core/database/database_manager.dart';

/// 数据库缓存管理器
/// 专门处理SQLite数据库缓存的存储和管理
class DatabaseCacheManager {
  static final DatabaseCacheManager _instance = DatabaseCacheManager._internal();
  static DatabaseCacheManager get instance => _instance;
  
  DatabaseCacheManager._internal();
  
  /// 设置数据库缓存
  Future<void> set(
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
  Future<T?> get<T>(String key) async {
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
  Future<void> remove(String key) async {
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
  Future<void> clear() async {
    try {
      await DatabaseManager.instance.delete('cache');
      LoggerUtil.cache('CLEAR_DATABASE', 'ALL');
    } catch (e) {
      LoggerUtil.e('清空数据库缓存失败: $e');
    }
  }
  
  /// 检查缓存是否存在
  Future<bool> contains(String key) async {
    try {
      final result = await DatabaseManager.instance.query(
        'cache',
        columns: ['expire_time'],
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      
      if (result.isEmpty) return false;
      
      final expireTime = result.first['expire_time'] as int;
      if (DateTime.now().millisecondsSinceEpoch > expireTime) {
        await remove(key);
        return false;
      }
      
      return true;
    } catch (e) {
      LoggerUtil.e('检查数据库缓存失败: $key, error: $e');
      return false;
    }
  }
  
  /// 获取所有缓存键
  Future<List<String>> getKeys() async {
    try {
      final result = await DatabaseManager.instance.query(
        'cache',
        columns: ['key'],
      );
      
      return result.map((row) => row['key'] as String).toList();
    } catch (e) {
      LoggerUtil.e('获取数据库缓存键失败: $e');
      return [];
    }
  }
  
  /// 获取缓存数量
  Future<int> getCount() async {
    try {
      final result = await DatabaseManager.instance.rawQuery(
        'SELECT COUNT(*) as count FROM cache',
      );
      
      return result.first['count'] as int;
    } catch (e) {
      LoggerUtil.e('获取数据库缓存数量失败: $e');
      return 0;
    }
  }
  
  /// 清理过期缓存
  Future<void> cleanExpired() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final deletedCount = await DatabaseManager.instance.delete(
        'cache',
        where: 'expire_time < ?',
        whereArgs: [now],
      );
      
      if (deletedCount > 0) {
        LoggerUtil.d('清理过期数据库缓存: ${deletedCount}个');
      }
    } catch (e) {
      LoggerUtil.e('清理过期数据库缓存失败: $e');
    }
  }
  
  /// 获取缓存项详细信息
  Future<Map<String, dynamic>?> getCacheInfo(String key) async {
    try {
      final result = await DatabaseManager.instance.query(
        'cache',
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      
      if (result.isEmpty) return null;
      
      final cacheData = result.first;
      return {
        'key': key,
        'value': jsonDecode(cacheData['value'] as String),
        'createdAt': DateTime.fromMillisecondsSinceEpoch(cacheData['created_at'] as int),
        'expireTime': DateTime.fromMillisecondsSinceEpoch(cacheData['expire_time'] as int),
        'isExpired': DateTime.now().millisecondsSinceEpoch > (cacheData['expire_time'] as int),
      };
    } catch (e) {
      LoggerUtil.e('获取数据库缓存信息失败: $key, error: $e');
      return null;
    }
  }
  
  /// 批量设置缓存
  Future<void> setBatch(Map<String, dynamic> data, {Duration? expiration}) async {
    try {
      final expireTime = expiration != null
          ? DateTime.now().add(expiration).millisecondsSinceEpoch
          : DateTime.now().add(Duration(milliseconds: AppConfig.cacheExpireTime)).millisecondsSinceEpoch;
      
      final batch = <Map<String, dynamic>>[];
      final now = DateTime.now().millisecondsSinceEpoch;
      
      data.forEach((key, value) {
        batch.add({
          'key': key,
          'value': jsonEncode(value),
          'expire_time': expireTime,
          'created_at': now,
        });
      });
      
      await DatabaseManager.instance.insertBatch('cache', batch);
      LoggerUtil.cache('SET_DATABASE_BATCH', '${data.length} items');
    } catch (e) {
      LoggerUtil.e('批量设置数据库缓存失败: $e');
    }
  }
  
  /// 批量获取缓存
  Future<Map<String, dynamic>> getBatch(List<String> keys) async {
    try {
      final result = <String, dynamic>{};
      
      for (final key in keys) {
        final value = await get(key);
        if (value != null) {
          result[key] = value;
        }
      }
      
      return result;
    } catch (e) {
      LoggerUtil.e('批量获取数据库缓存失败: $e');
      return {};
    }
  }
  
  /// 获取缓存统计信息
  Future<Map<String, dynamic>> getStats() async {
    try {
      final count = await getCount();
      final keys = await getKeys();
      
      // 统计过期缓存数量
      final now = DateTime.now().millisecondsSinceEpoch;
      final expiredResult = await DatabaseManager.instance.rawQuery(
        'SELECT COUNT(*) as count FROM cache WHERE expire_time < ?',
        [now],
      );
      final expiredCount = expiredResult.first['count'] as int;
      
      return {
        'count': count,
        'keys': keys,
        'expiredCount': expiredCount,
      };
    } catch (e) {
      LoggerUtil.e('获取数据库缓存统计失败: $e');
      return {
        'count': 0,
        'keys': <String>[],
        'expiredCount': 0,
      };
    }
  }
}