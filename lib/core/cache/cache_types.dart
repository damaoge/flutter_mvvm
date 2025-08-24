/// 缓存类型枚举
enum CacheType {
  /// 内存缓存（最快，但应用重启后丢失）
  memory,
  
  /// 持久化缓存（Hive，快速且持久）
  persistent,
  
  /// 数据库缓存（SQLite，可查询但较慢）
  database,
}

/// 缓存类型扩展
extension CacheTypeExtension on CacheType {
  /// 获取缓存类型名称
  String get name {
    switch (this) {
      case CacheType.memory:
        return '内存缓存';
      case CacheType.persistent:
        return '持久化缓存';
      case CacheType.database:
        return '数据库缓存';
    }
  }
  
  /// 获取缓存类型描述
  String get description {
    switch (this) {
      case CacheType.memory:
        return '存储在内存中，访问速度最快，但应用重启后数据丢失';
      case CacheType.persistent:
        return '使用Hive存储，访问速度快且数据持久化';
      case CacheType.database:
        return '使用SQLite存储，支持复杂查询但访问速度相对较慢';
    }
  }
  
  /// 获取推荐使用场景
  String get recommendedUse {
    switch (this) {
      case CacheType.memory:
        return '临时数据、频繁访问的小数据';
      case CacheType.persistent:
        return '用户设置、应用配置、中等大小的数据';
      case CacheType.database:
        return '大量数据、需要查询的结构化数据';
    }
  }
}