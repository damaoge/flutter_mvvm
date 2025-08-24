import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 内存缓存管理器
/// 专门处理内存缓存的存储和管理
class MemoryCacheManager {
  static final MemoryCacheManager _instance = MemoryCacheManager._internal();
  static MemoryCacheManager get instance => _instance;
  
  // 内存缓存存储
  final Map<String, CacheItem> _cache = {};
  
  MemoryCacheManager._internal();
  
  /// 设置内存缓存
  void set(
    String key,
    dynamic value, {
    Duration? expiration,
  }) {
    try {
      final expireTime = expiration != null
          ? DateTime.now().add(expiration)
          : null;
      
      _cache[key] = CacheItem(
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
  T? get<T>(String key) {
    try {
      final item = _cache[key];
      if (item == null) {
        LoggerUtil.cache('GET_MEMORY', key, value: 'NOT_FOUND');
        return null;
      }
      
      if (item.isExpired) {
        _cache.remove(key);
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
  void remove(String key) {
    try {
      _cache.remove(key);
      LoggerUtil.cache('REMOVE_MEMORY', key);
    } catch (e) {
      LoggerUtil.e('删除内存缓存失败: $key, error: $e');
    }
  }
  
  /// 清空内存缓存
  void clear() {
    try {
      _cache.clear();
      LoggerUtil.cache('CLEAR_MEMORY', 'ALL');
    } catch (e) {
      LoggerUtil.e('清空内存缓存失败: $e');
    }
  }
  
  /// 检查缓存是否存在
  bool contains(String key) {
    final item = _cache[key];
    if (item == null) return false;
    
    if (item.isExpired) {
      _cache.remove(key);
      return false;
    }
    
    return true;
  }
  
  /// 获取所有缓存键
  List<String> get keys => _cache.keys.toList();
  
  /// 获取缓存数量
  int get length => _cache.length;
  
  /// 清理过期缓存
  void cleanExpired() {
    final expiredKeys = <String>[];
    _cache.forEach((key, item) {
      if (item.isExpired) {
        expiredKeys.add(key);
      }
    });
    
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      LoggerUtil.d('清理过期内存缓存: ${expiredKeys.length}个');
    }
  }
  
  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    return {
      'count': _cache.length,
      'keys': _cache.keys.toList(),
      'expiredCount': _cache.values.where((item) => item.isExpired).length,
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
  
  /// 获取剩余生存时间
  Duration? get remainingTime {
    if (expireTime == null) return null;
    final remaining = expireTime!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}