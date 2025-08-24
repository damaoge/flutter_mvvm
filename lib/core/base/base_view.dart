import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'base_view_model.dart';
import '../utils/logger_util.dart';

/// View基类
/// 提供MVVM架构中View的基础功能
abstract class BaseView<T extends BaseViewModel> extends StatefulWidget {
  const BaseView({super.key});
  
  /// 创建ViewModel实例
  T createViewModel();
  
  /// 构建页面内容
  Widget buildContent(BuildContext context, T viewModel);
  
  /// 是否显示AppBar
  bool get showAppBar => true;
  
  /// AppBar标题
  String? get appBarTitle => null;
  
  /// AppBar操作按钮
  List<Widget>? get appBarActions => null;
  
  /// 是否可以返回
  bool get canPop => true;
  
  /// 背景颜色
  Color? get backgroundColor => null;
  
  /// 是否安全区域
  bool get useSafeArea => true;
  
  /// 是否可以调整大小
  bool get resizeToAvoidBottomInset => true;
  
  @override
  State<BaseView<T>> createState() => _BaseViewState<T>();
}

class _BaseViewState<T extends BaseViewModel> extends State<BaseView<T>>
    with WidgetsBindingObserver {
  late T _viewModel;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewModel = widget.createViewModel();
    _viewModel.init();
    
    // 监听ViewModel状态变化
    _viewModel.addListener(_onViewModelChanged);
    
    LoggerUtil.d('${widget.runtimeType} initialized');
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    LoggerUtil.d('${widget.runtimeType} disposed');
    super.dispose();
  }
  
  /// ViewModel状态变化回调
  void _onViewModelChanged() {
    if (!mounted) return;
    
    // 处理加载状态
    if (_viewModel.isLoading) {
      EasyLoading.show(status: '加载中...');
    } else {
      EasyLoading.dismiss();
    }
    
    // 处理错误信息
    if (_viewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(_viewModel.errorMessage!);
      });
    }
  }
  
  /// 显示错误对话框
  void _showErrorDialog(String message) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _viewModel.clearError();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    LoggerUtil.d('${widget.runtimeType} lifecycle state: $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        onResume();
        break;
      case AppLifecycleState.paused:
        onPause();
        break;
      case AppLifecycleState.detached:
        onDetached();
        break;
      case AppLifecycleState.inactive:
        onInactive();
        break;
      case AppLifecycleState.hidden:
        onHidden();
        break;
    }
  }
  
  /// 页面恢复
  void onResume() {}
  
  /// 页面暂停
  void onPause() {}
  
  /// 页面分离
  void onDetached() {}
  
  /// 页面非活跃
  void onInactive() {}
  
  /// 页面隐藏
  void onHidden() {}
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>.value(
      value: _viewModel,
      child: Consumer<T>(
        builder: (context, viewModel, child) {
          Widget body = widget.buildContent(context, viewModel);
          
          if (widget.useSafeArea) {
            body = SafeArea(child: body);
          }
          
          return Scaffold(
            backgroundColor: widget.backgroundColor,
            resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
            appBar: widget.showAppBar
                ? AppBar(
                    title: widget.appBarTitle != null
                        ? Text(widget.appBarTitle!)
                        : null,
                    actions: widget.appBarActions,
                    automaticallyImplyLeading: widget.canPop,
                  )
                : null,
            body: body,
          );
        },
      ),
    );
  }
}

/// 带刷新功能的View基类
abstract class BaseRefreshView<T extends BaseListViewModel>
    extends BaseView<T> {
  const BaseRefreshView({super.key});
  
  @override
  Widget buildContent(BuildContext context, T viewModel) {
    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: buildList(context, viewModel),
    );
  }
  
  /// 构建列表内容
  Widget buildList(BuildContext context, T viewModel);
}

/// 无状态View基类
abstract class BaseStatelessView extends StatelessWidget {
  const BaseStatelessView({super.key});
  
  /// 是否显示AppBar
  bool get showAppBar => true;
  
  /// AppBar标题
  String? get appBarTitle => null;
  
  /// AppBar操作按钮
  List<Widget>? get appBarActions => null;
  
  /// 是否可以返回
  bool get canPop => true;
  
  /// 背景颜色
  Color? get backgroundColor => null;
  
  /// 是否安全区域
  bool get useSafeArea => true;
  
  /// 构建页面内容
  Widget buildContent(BuildContext context);
  
  @override
  Widget build(BuildContext context) {
    Widget body = buildContent(context);
    
    if (useSafeArea) {
      body = SafeArea(child: body);
    }
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: showAppBar
          ? AppBar(
              title: appBarTitle != null ? Text(appBarTitle!) : null,
              actions: appBarActions,
              automaticallyImplyLeading: canPop,
            )
          : null,
      body: body,
    );
  }
}