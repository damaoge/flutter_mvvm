/// 基础数据源接口
/// 定义了数据源的通用操作
abstract class BaseDataSource<T, ID> {
  /// 根据ID获取数据
  Future<T?> getById(ID id);
  
  /// 获取所有数据
  Future<List<T>> getAll();
  
  /// 分页获取数据
  Future<List<T>> getPage(int page, int size);
  
  /// 保存数据
  Future<T> save(T data);
  
  /// 更新数据
  Future<T> update(T data);
  
  /// 删除数据
  Future<void> delete(ID id);
  
  /// 批量删除
  Future<void> deleteAll(List<ID> ids);
  
  /// 清空所有数据
  Future<void> clear();
}

/// 远程数据源接口
abstract class RemoteDataSource<T, ID> extends BaseDataSource<T, ID> {
  /// 同步数据到服务器
  Future<void> sync();
  
  /// 检查网络连接
  Future<bool> isConnected();
  
  /// 上传数据
  Future<T> upload(T data);
  
  /// 下载数据
  Future<T?> download(ID id);
}

/// 本地数据源接口
abstract class LocalDataSource<T, ID> extends BaseDataSource<T, ID> {
  /// 缓存数据
  Future<void> cache(T data);
  
  /// 从缓存获取数据
  Future<T?> getFromCache(ID id);
  
  /// 清除缓存
  Future<void> clearCache([ID? id]);
  
  /// 获取缓存大小
  Future<int> getCacheSize();
  
  /// 检查缓存是否过期
  Future<bool> isCacheExpired(ID id);
}

/// 数据源异常
class DataSourceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const DataSourceException(
    this.message, {
    this.code,
    this.originalError,
  });
  
  @override
  String toString() {
    return 'DataSourceException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// 网络异常
class NetworkException extends DataSourceException {
  const NetworkException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}

/// 缓存异常
class CacheException extends DataSourceException {
  const CacheException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);
}