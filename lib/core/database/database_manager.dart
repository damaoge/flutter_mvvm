import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../base/app_config.dart';
import '../utils/logger_util.dart';

/// 数据库管理器
/// 封装SQLite数据库操作
class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  static DatabaseManager get instance => _instance;
  
  Database? _database;
  
  DatabaseManager._internal();
  
  /// 初始化数据库
  Future<void> init() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, AppConfig.databaseName);
      
      _database = await openDatabase(
        path,
        version: AppConfig.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade,
      );
      
      LoggerUtil.i('数据库初始化完成: $path');
    } catch (e) {
      LoggerUtil.e('数据库初始化失败: $e');
      rethrow;
    }
  }
  
  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    try {
      // 创建用户表
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL UNIQUE,
          email TEXT,
          avatar TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      
      // 创建缓存表
      await db.execute('''
        CREATE TABLE cache (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          expire_time INTEGER NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');
      
      // 创建设置表
      await db.execute('''
        CREATE TABLE settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          type TEXT NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      
      LoggerUtil.i('数据库表创建完成');
    } catch (e) {
      LoggerUtil.e('创建数据库表失败: $e');
      rethrow;
    }
  }
  
  /// 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    LoggerUtil.i('数据库升级: $oldVersion -> $newVersion');
    
    // 根据版本号执行相应的升级脚本
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _upgradeToVersion(db, version);
    }
  }
  
  /// 降级数据库
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    LoggerUtil.w('数据库降级: $oldVersion -> $newVersion');
    // 通常不建议降级，这里可以根据需要实现
  }
  
  /// 升级到指定版本
  Future<void> _upgradeToVersion(Database db, int version) async {
    switch (version) {
      case 2:
        // 版本2的升级脚本
        await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
        break;
      case 3:
        // 版本3的升级脚本
        await db.execute('''
          CREATE TABLE logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            level TEXT NOT NULL,
            message TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
        break;
      default:
        LoggerUtil.w('未知的数据库版本: $version');
    }
  }
  
  /// 确保数据库已初始化
  void _ensureInitialized() {
    if (_database == null) {
      throw Exception('数据库未初始化，请先调用init()方法');
    }
  }
  
  /// 插入数据
  Future<int> insert(String table, Map<String, dynamic> values) async {
    _ensureInitialized();
    try {
      final id = await _database!.insert(
        table,
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      LoggerUtil.database('INSERT', table, data: values);
      return id;
    } catch (e) {
      LoggerUtil.e('插入数据失败: $table, error: $e');
      rethrow;
    }
  }
  
  /// 查询数据
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    _ensureInitialized();
    try {
      final result = await _database!.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      LoggerUtil.database('SELECT', table, data: {
        'where': where,
        'whereArgs': whereArgs,
        'count': result.length,
      });
      return result;
    } catch (e) {
      LoggerUtil.e('查询数据失败: $table, error: $e');
      rethrow;
    }
  }
  
  /// 更新数据
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    _ensureInitialized();
    try {
      final count = await _database!.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
      );
      LoggerUtil.database('UPDATE', table, data: {
        'values': values,
        'where': where,
        'whereArgs': whereArgs,
        'affected': count,
      });
      return count;
    } catch (e) {
      LoggerUtil.e('更新数据失败: $table, error: $e');
      rethrow;
    }
  }
  
  /// 删除数据
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    _ensureInitialized();
    try {
      final count = await _database!.delete(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      LoggerUtil.database('DELETE', table, data: {
        'where': where,
        'whereArgs': whereArgs,
        'affected': count,
      });
      return count;
    } catch (e) {
      LoggerUtil.e('删除数据失败: $table, error: $e');
      rethrow;
    }
  }
  
  /// 执行原生SQL
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [List<dynamic>? arguments]
  ) async {
    _ensureInitialized();
    try {
      final result = await _database!.rawQuery(sql, arguments);
      LoggerUtil.database('RAW_QUERY', 'sql', data: {
        'sql': sql,
        'arguments': arguments,
        'count': result.length,
      });
      return result;
    } catch (e) {
      LoggerUtil.e('执行SQL查询失败: $sql, error: $e');
      rethrow;
    }
  }
  
  /// 执行原生SQL（无返回值）
  Future<void> rawExecute(String sql, [List<dynamic>? arguments]) async {
    _ensureInitialized();
    try {
      await _database!.execute(sql, arguments);
      LoggerUtil.database('RAW_EXECUTE', 'sql', data: {
        'sql': sql,
        'arguments': arguments,
      });
    } catch (e) {
      LoggerUtil.e('执行SQL失败: $sql, error: $e');
      rethrow;
    }
  }
  
  /// 批量操作
  Future<List<dynamic>> batch(Function(Batch batch) operations) async {
    _ensureInitialized();
    try {
      final batch = _database!.batch();
      operations(batch);
      final result = await batch.commit();
      LoggerUtil.database('BATCH', 'operations', data: {
        'count': result.length,
      });
      return result;
    } catch (e) {
      LoggerUtil.e('批量操作失败: $e');
      rethrow;
    }
  }
  
  /// 事务操作
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    _ensureInitialized();
    try {
      final result = await _database!.transaction(action);
      LoggerUtil.database('TRANSACTION', 'action');
      return result;
    } catch (e) {
      LoggerUtil.e('事务操作失败: $e');
      rethrow;
    }
  }
  
  /// 获取表信息
  Future<List<Map<String, dynamic>>> getTableInfo(String tableName) async {
    return await rawQuery('PRAGMA table_info($tableName)');
  }
  
  /// 检查表是否存在
  Future<bool> tableExists(String tableName) async {
    final result = await rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }
  
  /// 获取数据库版本
  Future<int> getDatabaseVersion() async {
    _ensureInitialized();
    return await _database!.getVersion();
  }
  
  /// 关闭数据库
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      LoggerUtil.i('数据库已关闭');
    }
  }
  
  /// 删除数据库文件
  Future<void> deleteDatabase() async {
    try {
      await close();
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, AppConfig.databaseName);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        LoggerUtil.i('数据库文件已删除: $path');
      }
    } catch (e) {
      LoggerUtil.e('删除数据库文件失败: $e');
      rethrow;
    }
  }
}