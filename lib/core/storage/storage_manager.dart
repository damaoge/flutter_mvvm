import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 存储管理器
/// 基于SharedPreferences的轻量级存储解决方案
class StorageManager {
  static final StorageManager _instance = StorageManager._internal();
  static StorageManager get instance => _instance;
  
  SharedPreferences? _prefs;
  
  StorageManager._internal();
  
  /// 初始化存储管理器
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      LoggerUtil.i('存储管理器初始化完成');
    } catch (e) {
      LoggerUtil.e('存储管理器初始化失败: $e');
      rethrow;
    }
  }
  
  /// 确保已初始化
  void _ensureInitialized() {
    if (_prefs == null) {
      throw Exception('StorageManager未初始化，请先调用init()方法');
    }
  }
  
  /// 存储字符串
  Future<bool> setString(String key, String value) async {
    _ensureInitialized();
    try {
      final result = await _prefs!.setString(key, value);
      LoggerUtil.d('存储字符串: $key = $value');
      return result;
    } catch (e) {
      LoggerUtil.e('存储字符串失败: $key, error: $e');
      return false;
    }
  }
  
  /// 获取字符串
  String? getString(String key, {String? defaultValue}) {
    _ensureInitialized();
    try {
      final value = _prefs!.getString(key) ?? defaultValue;
      LoggerUtil.d('获取字符串: $key = $value');
      return value;
    } catch (e) {
      LoggerUtil.e('获取字符串失败: $key, error: $e');
      return defaultValue;
    }
  }
  
  /// 存储整数
  Future<bool> setInt(String key, int value) async {
    _ensureInitialized();
    try {
      final result = await _prefs!.setInt(key, value);
      LoggerUtil.d('存储整数: $key = $value');
      return result;
    } catch (e) {
      LoggerUtil.e('存储整数失败: $key, error: $e');
      return false;
    }
  }
  
  /// 获取整数
  int? getInt(String key, {int? defaultValue}) {
    _ensureInitialized();
    try {
      final value = _prefs!.getInt(key) ?? defaultValue;
      LoggerUtil.d('获取整数: $key = $value');
      return value;
    } catch (e) {
      LoggerUtil.e('获取整数失败: $key, error: $e');
      return defaultValue;
    }
  }
  
  /// 存储双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    _ensureInitialized();
    try {
      final result = await _prefs!.setDouble(key, value);
      LoggerUtil.d('存储双精度浮点数: $key = $value');
      return result;
    } catch (e) {
      LoggerUtil.e('存储双精度浮点数失败: $key, error: $e');
      return false;
    }
  }
  
  /// 获取双精度浮点数
  double? getDouble(String key, {double? defaultValue}) {
    _ensureInitialized();
    try {
      final value = _prefs!.getDouble(key) ?? defaultValue;
      LoggerUtil.d('获取双精度浮点数: $key = $value');
      return value;
    } catch (e) {
      LoggerUtil.e('获取双精度浮点数失败: $key, error: $e');
      return defaultValue;
    }
  }
  
  /// 存储布尔值
  Future<bool> setBool(String key, bool value) async {
    _ensureInitialized();
    try {
      final result = await _prefs!.setBool(key, value);
      LoggerUtil.d('存储布尔值: $key = $value');
      return result;
    } catch (e) {
      LoggerUtil.e('存储布尔值失败: $key, error: $e');
      return false;
    }
  }
  
  /// 获取布尔值
  bool? getBool(String key, {bool? defaultValue}) {
    _ensureInitialized();
    try {
      final value = _prefs!.getBool(key) ?? defaultValue;
      LoggerUtil.d('获取布尔值: $key = $value');
      return value;
    } catch (e) {
      LoggerUtil.e('获取布尔值失败: $key, error: $e');
      return defaultValue;
    }
  }
  
  /// 存储字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    _ensureInitialized();
    try {
      final result = await _prefs!.setStringList(key, value);
      LoggerUtil.d('存储字符串列表: $key = $value');
      return result;
    } catch (e) {
      LoggerUtil.e('存储字符串列表失败: $key, error: $e');
      return false;
    }
  }
  
  /// 获取字符串列表
  List<String>? getStringList(String key, {List<String>? defaultValue}) {
    _ensureInitialized();
    try {
      final value = _prefs!.getStringList(key) ?? defaultValue;
      LoggerUtil.d('获取字符串列表: $key = $value');
      return value;
    } catch (e) {
      LoggerUtil.e('获取字符串列表失败: $key, error: $e');
      return defaultValue;
    }
  }
  
  /// 存储JSON对象
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
  Map<String, dynamic>? getJson(String key, {Map<String, dynamic>? defaultValue}) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return defaultValue;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      LoggerUtil.e('获取JSON对象失败: $key, error: $e');
      return defaultValue;
    }
  }
  
  /// 检查键是否存在
  bool containsKey(String key) {
    _ensureInitialized();
    try {
      final exists = _prefs!.containsKey(key);
      LoggerUtil.d('检查键是否存在: $key = $exists');
      return exists;
    } catch (e) {
      LoggerUtil.e('检查键是否存在失败: $key, error: $e');
      return false;
    }
  }
  
  /// 删除指定键
  Future<bool> remove(String key) async {
    _ensureInitialized();
    try {
      final result = await _prefs!.remove(key);
      LoggerUtil.d('删除键: $key');
      return result;
    } catch (e) {
      LoggerUtil.e('删除键失败: $key, error: $e');
      return false;
    }
  }
  
  /// 清空所有数据
  Future<bool> clear() async {
    _ensureInitialized();
    try {
      final result = await _prefs!.clear();
      LoggerUtil.d('清空所有存储数据');
      return result;
    } catch (e) {
      LoggerUtil.e('清空存储数据失败: $e');
      return false;
    }
  }
  
  /// 获取所有键
  Set<String> getKeys() {
    _ensureInitialized();
    try {
      final keys = _prefs!.getKeys();
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