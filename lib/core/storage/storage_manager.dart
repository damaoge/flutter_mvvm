import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 存储管理器接口
abstract class IStorageManager {
  Future<bool> setString(String key, String value);
  String? getString(String key, {String? defaultValue});
  Future<bool> setInt(String key, int value);
  int? getInt(String key, {int? defaultValue});
  Future<bool> setDouble(String key, double value);
  double? getDouble(String key, {double? defaultValue});
  Future<bool> setBool(String key, bool value);
  bool? getBool(String key, {bool? defaultValue});
  Future<bool> setStringList(String key, List<String> value);
  List<String>? getStringList(String key, {List<String>? defaultValue});
  Future<bool> setJson(String key, Map<String, dynamic> value);
  Map<String, dynamic>? getJson(String key);
  Future<bool> remove(String key);
  Future<bool> clear();
  bool containsKey(String key);
  Set<String> getKeys();
}

/// 存储管理器实现
/// 基于SharedPreferences的轻量级存储解决方案
@LazySingleton(as: IStorageManager)
class StorageManager implements IStorageManager {
  final SharedPreferences _prefs;
  
  StorageManager(this._prefs);
  

  
  /// 存储字符串
  @override
  Future<bool> setString(String key, String value) async {
    try {
      final result = await _prefs.setString(key, value);
      LoggerUtil.d('存储字符串: $key = $value');
      return result;
    } catch (e) {
      LoggerUtil.e('存储字符串失败: $key, error: $e');
      return false;
    }
  }
  
  /// 获取字符串
  @override
  String? getString(String key, {String? defaultValue}) {
    try {
      final value = _prefs.getString(key) ?? defaultValue;
      LoggerUtil.d('获取字符串: $key = $value');
      return value;
    } catch (e) {
      LoggerUtil.e('获取字符串失败: $key, error: $e');
      return defaultValue;
    }
  }
  
  /// 存储整数
  @override
  Future<bool> setInt(String key, int value) async {
    try {
      final result = await _prefs.setInt(key, value);
      LoggerUtil.d('存储整数: $key = $value');
      return result;
    } catch (e) {
      LoggerUtil.e('存储整数失败: $key, error: $e');
      return false;
    }
  }
  
  /// 获取整数
  @override
  int? getInt(String key, {int? defaultValue}) {
    try {
      final value = _prefs.getInt(key) ?? defaultValue;
      LoggerUtil.d('获取整数: $key = $value');
      return value;
    } catch (e) {
      LoggerUtil.e('获取整数失败: $key, error: $e');
      return defaultValue;
    }
  }
  
  /// 存储双精度浮点数
  @override
  Future<bool> setDouble(String key, double value) async {
    try {
      final result = await _prefs.setDouble(key, value);
      LoggerUtil.d('存储双精度浮点数: $key = $value');
      return result;
    } catch (e) {
      LoggerUtil.e('存储双精度浮点数失败: $key, error: $e');
      return false;
    }
  }
  
  /// 获取双精度浮点数
  @override
  double? getDouble(String key, {double? defaultValue}) {
    try {
      final value = _prefs.getDouble(key) ?? defaultValue;
      LoggerUtil.d('获取双精度浮点数: $key = $value');
      return value;
    } catch (e) {
      LoggerUtil.e('获取双精度浮点数失败: $key, error: $e');
      return defaultValue;
    }
  }
  
  /// 存储布尔值
  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      final result = await _prefs.setBool(key, value);
      LoggerUtil.d('存储布尔值: $key = $value');
      return result;
    } catch (e) {
      LoggerUtil.e('存储布尔值失败: $key, error: $e');
      return false;
    }
  }
  
  /// 获取布尔值
  @override
  bool? getBool(String key, {bool? defaultValue}) {
    try {
      final value = _prefs.getBool(key) ?? defaultValue;
      LoggerUtil.d('获取布尔值: $key = $value');
      return value;
    } catch (e) {
      LoggerUtil.e('获取布尔值失败: $key, error: $e');
      return defaultValue;
    }
  }
  
  /// 存储字符串列表
  @override
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final result = await _prefs.setStringList(key, value);
      LoggerUtil.d('存储字符串列表: $key = $value');
      return result;
    } catch (e) {
      LoggerUtil.e('存储字符串列表失败: $key, error: $e');
      return false;
    }
  }
  
  /// 获取字符串列表
  @override
  List<String>? getStringList(String key, {List<String>? defaultValue}) {
    try {
      final value = _prefs.getStringList(key) ?? defaultValue;
      LoggerUtil.d('获取字符串列表: $key = $value');
      return value;
    } catch (e) {
      LoggerUtil.e('获取字符串列表失败: $key, error: $e');
      return defaultValue;
    }
  }
  
  /// 存储JSON对象
  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return await setString(key, jsonString);
    } catch (e) {
      LoggerUtil.e('存储JSON对象失败: $key, error: $e');
      return false;
    }
  }
  
  /// 获取JSON对象
  @override
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      LoggerUtil.e('获取JSON对象失败: $key, error: $e');
      return null;
    }
  }
  
  /// 检查键是否存在
  @override
  bool containsKey(String key) {
    try {
      final exists = _prefs.containsKey(key);
      LoggerUtil.d('检查键是否存在: $key = $exists');
      return exists;
    } catch (e) {
      LoggerUtil.e('检查键是否存在失败: $key, error: $e');
      return false;
    }
  }
  
  /// 删除指定键
  @override
  Future<bool> remove(String key) async {
    try {
      final result = await _prefs.remove(key);
      LoggerUtil.d('删除键: $key');
      return result;
    } catch (e) {
      LoggerUtil.e('删除键失败: $key, error: $e');
      return false;
    }
  }
  
  /// 清空所有数据
  @override
  Future<bool> clear() async {
    try {
      final result = await _prefs.clear();
      LoggerUtil.d('清空所有存储数据');
      return result;
    } catch (e) {
      LoggerUtil.e('清空存储数据失败: $e');
      return false;
    }
  }
  
  /// 获取所有键
  @override
  Set<String> getKeys() {
    try {
      final keys = _prefs.getKeys();
      LoggerUtil.d('获取所有键: $keys');
      return keys;
    } catch (e) {
      LoggerUtil.e('获取所有键失败: $e');
      return <String>{};
    }
  }
  
  /// 重新加载数据
  Future<void> reload() async {
    _ensureInitialized();
    try {
      await _prefs!.reload();
      LoggerUtil.d('重新加载存储数据');
    } catch (e) {
      LoggerUtil.e('重新加载存储数据失败: $e');
    }
  }
}