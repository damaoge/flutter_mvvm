import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:flutter_mvvm/core/datasource/base_datasource.dart';
import 'package:flutter_mvvm/core/storage/storage_manager.dart';

/// 本地数据源实现
@LazySingleton(as: LocalDataSource)
class LocalDataSourceImpl implements LocalDataSource {
  final IStorageManager _storageManager;
  
  // 缓存键前缀
  static const String _cachePrefix = 'cache_';
  static const String _metaPrefix = 'meta_';
  static const String _pendingPrefix = 'pending_';

  LocalDataSourceImpl(this._storageManager);

  @override
  Future<Map<String, dynamic>?> get(String key) async {
    try {
      final jsonString = await _storageManager.getString('$_cachePrefix$key');
      if (jsonString != null && jsonString.isNotEmpty) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw CacheException('获取本地数据失败: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String collectionKey) async {
    try {
      final jsonString = await _storageManager.getString('$_cachePrefix${collectionKey}_list');
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw CacheException('获取本地数据列表失败: $e');
    }
  }

  @override
  Future<void> save(String key, Map<String, dynamic> data) async {
    try {
      final jsonString = json.encode(data);
      await _storageManager.setString('$_cachePrefix$key', jsonString);
      
      // 保存元数据
      await _saveMetadata(key, {
        'lastUpdated': DateTime.now().toIso8601String(),
        'size': jsonString.length,
      });
    } catch (e) {
      throw CacheException('保存本地数据失败: $e');
    }
  }

  @override
  Future<void> saveAll(String collectionKey, List<Map<String, dynamic>> dataList) async {
    try {
      final jsonString = json.encode(dataList);
      await _storageManager.setString('$_cachePrefix${collectionKey}_list', jsonString);
      
      // 保存元数据
      await _saveMetadata('${collectionKey}_list', {
        'lastUpdated': DateTime.now().toIso8601String(),
        'count': dataList.length,
        'size': jsonString.length,
      });
    } catch (e) {
      throw CacheException('保存本地数据列表失败: $e');
    }
  }

  @override
  Future<bool> delete(String key) async {
    try {
      await _storageManager.remove('$_cachePrefix$key');
      await _storageManager.remove('$_metaPrefix$key');
      return true;
    } catch (e) {
      throw CacheException('删除本地数据失败: $e');
    }
  }

  @override
  Future<bool> exists(String key) async {
    try {
      return await _storageManager.containsKey('$_cachePrefix$key');
    } catch (e) {
      throw CacheException('检查本地数据存在性失败: $e');
    }
  }

  @override
  Future<bool> clear(String? pattern) async {
    try {
      final keys = await _storageManager.getKeys();
      final keysToDelete = <String>[];
      
      if (pattern != null) {
        // 删除匹配模式的键
        final targetPattern = '$_cachePrefix$pattern';
        for (final key in keys) {
          if (key.contains(targetPattern)) {
            keysToDelete.add(key);
          }
        }
      } else {
        // 删除所有缓存键
        for (final key in keys) {
          if (key.startsWith(_cachePrefix) || key.startsWith(_metaPrefix)) {
            keysToDelete.add(key);
          }
        }
      }
      
      for (final key in keysToDelete) {
        await _storageManager.remove(key);
      }
      
      return true;
    } catch (e) {
      throw CacheException('清除本地数据失败: $e');
    }
  }

  @override
  Future<DateTime?> getLastUpdated(String key) async {
    try {
      final metadata = await _getMetadata(key);
      if (metadata != null && metadata.containsKey('lastUpdated')) {
        return DateTime.parse(metadata['lastUpdated']);
      }
      return null;
    } catch (e) {
      throw CacheException('获取最后更新时间失败: $e');
    }
  }

  @override
  Future<bool> isExpired(String key, Duration maxAge) async {
    try {
      final lastUpdated = await getLastUpdated(key);
      if (lastUpdated == null) return true;
      
      final now = DateTime.now();
      return now.difference(lastUpdated) > maxAge;
    } catch (e) {
      throw CacheException('检查数据过期状态失败: $e');
    }
  }

  @override
  Future<int> getSize(String key) async {
    try {
      final metadata = await _getMetadata(key);
      if (metadata != null && metadata.containsKey('size')) {
        return metadata['size'] as int;
      }
      return 0;
    } catch (e) {
      throw CacheException('获取数据大小失败: $e');
    }
  }

  @override
  Future<void> addPendingChange(String key, Map<String, dynamic> change) async {
    try {
      final pendingKey = '$_pendingPrefix$key';
      final existingChanges = await _getPendingChanges(key);
      existingChanges.add({
        ...change,
        'timestamp': DateTime.now().toIso8601String(),
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      
      final jsonString = json.encode(existingChanges);
      await _storageManager.setString(pendingKey, jsonString);
    } catch (e) {
      throw CacheException('添加待同步更改失败: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingChanges(String key) async {
    return await _getPendingChanges(key);
  }

  @override
  Future<void> clearPendingChanges(String key) async {
    try {
      await _storageManager.remove('$_pendingPrefix$key');
    } catch (e) {
      throw CacheException('清除待同步更改失败: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllPendingChanges() async {
    try {
      final keys = await _storageManager.getKeys();
      final allChanges = <Map<String, dynamic>>[];
      
      for (final key in keys) {
        if (key.startsWith(_pendingPrefix)) {
          final originalKey = key.substring(_pendingPrefix.length);
          final changes = await _getPendingChanges(originalKey);
          allChanges.addAll(changes);
        }
      }
      
      return allChanges;
    } catch (e) {
      throw CacheException('获取所有待同步更改失败: $e');
    }
  }

  /// 保存元数据
  Future<void> _saveMetadata(String key, Map<String, dynamic> metadata) async {
    final jsonString = json.encode(metadata);
    await _storageManager.setString('$_metaPrefix$key', jsonString);
  }

  /// 获取元数据
  Future<Map<String, dynamic>?> _getMetadata(String key) async {
    final jsonString = await _storageManager.getString('$_metaPrefix$key');
    if (jsonString != null && jsonString.isNotEmpty) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  /// 获取待同步更改
  Future<List<Map<String, dynamic>>> _getPendingChanges(String key) async {
    try {
      final jsonString = await _storageManager.getString('$_pendingPrefix$key');
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      throw CacheException('获取待同步更改失败: $e');
    }
  }
}