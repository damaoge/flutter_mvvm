import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 持久化缓存管理器
/// 专门处理Hive持久化缓存的存储和管理
class PersistentCacheManager {
  static final PersistentCacheManager _instance = PersistentCacheManager._internal();
  static PersistentCacheManager get instance => _instance;
  
  // Hive缓存盒子
  Box<String>? _cacheBox;
  
  PersistentCacheManager._internal();
  
  /// 初始化持久化缓存
  Future<void> init() async {
    try {
      _cacheBox = await Hive.openBox<String>('cache_box');
      await cleanExpired();
      LoggerUtil.i('持久化缓存管理器初始化完成');
    } catch (e) {
      LoggerUtil.e('持久化缓存管理器初始化失败: $e');
      rethrow;
    }
  }
  
  /// 设置持久化缓存
  Future<void> set(
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
  
  /// 获取持久化缓存
  Future<T?> get<T>(String key) async {
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
  Future<void> remove(String key) async {
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
  Future<void> clear() async {
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
  
  /// 检查缓存是否存在
  Future<bool> contains(String key) async {
    try {
      if (_cacheBox == null) return false;
      
      final cacheDataString = _cacheBox!.get(key);
      if (cacheDataString == null) return false;
      
      final cacheData = jsonDecode(cacheDataString) as Map<String, dynamic>;
      final expireTime = cacheData['expireTime'] as int?;
      
      if (expireTime != null && DateTime.now().millisecondsSinceEpoch > expireTime) {
        await _cacheBox!.delete(key);
        return false;
      }
      
      return true;
    } catch (e) {
      LoggerUtil.e('检查持久化缓存失败: $key, error: $e');
      return false;
    }
  }
  
  /// 获取所有缓存键
  List<String> get keys {
    if (_cacheBox == null) return [];
    return _cacheBox!.keys.cast<String>().toList();
  }
  
  /// 获取缓存数量
  int get length => _cacheBox?.length ?? 0;
  
  /// 清理过期缓存
  Future<void> cleanExpired() async {
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
  
  /// 获取缓存项详细信息
  Future<Map<String, dynamic>?> getCacheInfo(String key) async {
    try {
      if (_cacheBox == null) return null;
      
      final cacheDataString = _cacheBox!.get(key);
      if (cacheDataString == null) return null;
      
      final cacheData = jsonDecode(cacheDataString) as Map<String, dynamic>;
      return {
        'key': key,
        'value': cacheData['value'],
        'createdAt': DateTime.fromMillisecondsSinceEpoch(cacheData['createdAt']),
        'expireTime': cacheData['expireTime'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(cacheData['expireTime'])
            : null,
        'isExpired': cacheData['expireTime'] != null 
            ? DateTime.now().millisecondsSinceEpoch > cacheData['expireTime']
            : false,
      };
    } catch (e) {
      LoggerUtil.e('获取缓存信息失败: $key, error: $e');
      return null;
    }
  }
  
  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    return {
      'count': _cacheBox?.length ?? 0,
      'keys': keys,
      'isInitialized': _cacheBox != null,
    };
  }
  
  /// 关闭缓存盒子
  Future<void> close() async {
    try {
      await _cacheBox?.close();
      _cacheBox = null;
      LoggerUtil.i('持久化缓存管理器已关闭');
    } catch (e) {
      LoggerUtil.e('关闭持久化缓存管理器失败: $e');
    }
  }
}