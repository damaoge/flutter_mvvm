import 'package:flutter_mvvm/core/base/base_view_model.dart';
import 'package:flutter_mvvm/core/router/router_manager.dart';

/// BaseViewModel路由跳转扩展
/// 提供统一的页面导航功能
extension BaseViewModelNavigationExtension on BaseViewModel {
  /// 跳转到指定页面
  Future<T?> navigateTo<T extends Object?>(
    String routeName, {
    dynamic arguments,
    bool preventDuplicates = true,
  }) async {
    return await RouterManager.instance.push<T>(
      routeName,
      arguments: arguments,
      preventDuplicates: preventDuplicates,
    );
  }

  /// 替换当前页面
  Future<T?> navigateReplace<T extends Object?, TO extends Object?>(
    String routeName, {
    dynamic arguments,
    TO? result,
  }) async {
    return await RouterManager.instance.pushReplacement<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// 清空栈并跳转到指定页面
  Future<T?> navigateAndClearStack<T extends Object?>(
    String routeName, {
    dynamic arguments,
  }) async {
    return await RouterManager.instance.pushAndClearStack<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// 返回上一页
  void navigateBack<T extends Object?>([T? result]) {
    RouterManager.instance.pop<T>(result);
  }

  /// 返回到指定页面
  void navigateBackTo(String routeName) {
    RouterManager.instance.popUntil(routeName);
  }
}