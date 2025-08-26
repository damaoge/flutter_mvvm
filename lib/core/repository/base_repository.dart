/// 基础Repository接口
/// 定义了通用的数据访问方法
abstract class BaseRepository<T, ID> {
  /// 根据ID获取单个实体
  Future<T?> getById(ID id);
  
  /// 获取所有实体
  Future<List<T>> getAll();
  
  /// 分页获取实体列表
  Future<List<T>> getPage(int page, int size);
  
  /// 创建新实体
  Future<T> create(T entity);
  
  /// 更新实体
  Future<T> update(T entity);
  
  /// 删除实体
  Future<void> delete(ID id);
  
  /// 批量删除
  Future<void> deleteAll(List<ID> ids);
  
  /// 检查实体是否存在
  Future<bool> exists(ID id);
  
  /// 获取实体总数
  Future<int> count();
  
  /// 清空所有数据
  Future<void> clear();
}

/// 可搜索的Repository接口
abstract class SearchableRepository<T, ID> extends BaseRepository<T, ID> {
  /// 根据关键词搜索
  Future<List<T>> search(String keyword, {int? page, int? size});
  
  /// 根据条件过滤
  Future<List<T>> filter(Map<String, dynamic> filters, {int? page, int? size});
}

/// 可缓存的Repository接口
abstract class CacheableRepository<T, ID> extends BaseRepository<T, ID> {
  /// 从缓存获取数据
  Future<T?> getFromCache(ID id);
  
  /// 缓存数据
  Future<void> cacheData(ID id, T data);
  
  /// 清除缓存
  Future<void> clearCache([ID? id]);
  
  /// 刷新缓存
  Future<T?> refreshCache(ID id);
}