import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';
import 'package:flutter_mvvm/core/permissions/permission_result.dart';

// 导入扩展方法
import 'package:flutter_mvvm/core/base/extensions/base_view_model_permission_extension.dart';
import 'package:flutter_mvvm/core/base/extensions/base_view_model_navigation_extension.dart';
import 'package:flutter_mvvm/core/base/extensions/base_view_model_dialog_extension.dart';

/// ViewModel基类
/// 提供MVVM架构中ViewModel的基础功能
/// 包含统一的权限管理、路由跳转、弹窗提示等功能
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isDisposed = false;
  String? _errorMessage;
  
  /// 是否正在加载
  bool get isLoading => _isLoading;
  
  /// 错误信息
  String? get errorMessage => _errorMessage;
  
  /// 是否已销毁
  bool get isDisposed => _isDisposed;
  
  /// 设置加载状态
  void setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    if (loading) {
      _errorMessage = null;
    }
    notifyListeners();
  }
  
  /// 设置错误信息
  void setError(String? error) {
    if (_isDisposed) return;
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
    if (error != null) {
      LoggerUtil.e('ViewModel Error: $error');
    }
  }
  
  /// 清除错误信息
  void clearError() {
    if (_isDisposed) return;
    _errorMessage = null;
    notifyListeners();
  }
  
  /// 安全执行异步操作
  Future<T?> safeExecute<T>(
    Future<T> Function() operation, {
    bool showLoading = true,
    String? errorPrefix,
  }) async {
    if (_isDisposed) return null;
    
    try {
      if (showLoading) setLoading(true);
      
      final result = await operation();
      
      if (showLoading) setLoading(false);
      clearError();
      
      return result;
    } catch (e) {
      final errorMsg = errorPrefix != null ? '$errorPrefix: $e' : e.toString();
      setError(errorMsg);
      return null;
    }
  }
  
  // ==================== 权限管理 ====================
  // 权限相关方法已移至 BaseViewModelPermissionExtension 扩展中
  
  // ==================== 路由跳转 ====================
  // 路由相关方法已移至 BaseViewModelNavigationExtension 扩展中
  
  // ==================== 弹窗和提示 ====================
  // 弹窗和提示相关方法已移至 BaseViewModelDialogExtension 扩展中
  
  // ==================== 生命周期 ====================
  
  /// 初始化方法，子类可重写
  void init() {
    LoggerUtil.d('${runtimeType} initialized');
  }
  
  /// 销毁方法，子类可重写
  void onDispose() {
    LoggerUtil.d('${runtimeType} disposed');
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    onDispose();
    super.dispose();
  }
  
  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}

/// 带分页功能的ViewModel基类
abstract class BaseListViewModel<T> extends BaseViewModel {
  List<T> _items = [];
  bool _hasMore = true;
  int _currentPage = 1;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  
  /// 数据列表
  List<T> get items => List.unmodifiable(_items);
  
  /// 是否还有更多数据
  bool get hasMore => _hasMore;
  
  /// 当前页码
  int get currentPage => _currentPage;
  
  /// 是否正在刷新
  bool get isRefreshing => _isRefreshing;
  
  /// 是否正在加载更多
  bool get isLoadingMore => _isLoadingMore;
  
  /// 每页数据量
  int get pageSize => 20;
  
  /// 刷新数据
  Future<void> refresh() async {
    if (_isDisposed) return;
    
    _isRefreshing = true;
    _currentPage = 1;
    notifyListeners();
    
    try {
      final newItems = await loadData(_currentPage, pageSize);
      _items = newItems ?? [];
      _hasMore = (newItems?.length ?? 0) >= pageSize;
      clearError();
    } catch (e) {
      setError('刷新失败: $e');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }
  
  /// 加载更多数据
  Future<void> loadMore() async {
    if (_isDisposed || !_hasMore || _isLoadingMore) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    try {
      final newItems = await loadData(_currentPage + 1, pageSize);
      if (newItems != null && newItems.isNotEmpty) {
        _items.addAll(newItems);
        _currentPage++;
        _hasMore = newItems.length >= pageSize;
      } else {
        _hasMore = false;
      }
      clearError();
    } catch (e) {
      setError('加载更多失败: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  /// 子类需要实现的数据加载方法
  Future<List<T>?> loadData(int page, int size);
  
  /// 添加单个项目
  void addItem(T item) {
    if (_isDisposed) return;
    _items.add(item);
    notifyListeners();
  }
  
  /// 移除单个项目
  void removeItem(T item) {
    if (_isDisposed) return;
    _items.remove(item);
    notifyListeners();
  }
  
  /// 更新单个项目
  void updateItem(int index, T item) {
    if (_isDisposed || index < 0 || index >= _items.length) return;
    _items[index] = item;
    notifyListeners();
  }
  
  /// 清空数据
  void clearItems() {
    if (_isDisposed) return;
    _items.clear();
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }
}