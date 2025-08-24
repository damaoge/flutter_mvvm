import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../theme/theme_manager.dart';
import '../screen/screen_adapter.dart';
import '../utils/logger_util.dart';

/// 统一的等待弹窗管理器
/// 提供加载、成功、错误等各种状态的弹窗显示
class LoadingDialog {
  static final LoadingDialog _instance = LoadingDialog._internal();
  static LoadingDialog get instance => _instance;
  
  LoadingDialog._internal();
  
  /// 初始化加载弹窗
  static void init() {
    try {
      EasyLoading.instance
        ..displayDuration = const Duration(milliseconds: 2000)
        ..indicatorType = EasyLoadingIndicatorType.fadingCircle
        ..loadingStyle = EasyLoadingStyle.custom
        ..indicatorSize = 45.0
        ..radius = 10.0
        ..progressColor = AppTheme.primaryColor
        ..backgroundColor = Colors.white
        ..indicatorColor = AppTheme.primaryColor
        ..textColor = AppTheme.textPrimaryLight
        ..maskColor = Colors.black.withOpacity(0.5)
        ..userInteractions = false
        ..dismissOnTap = false
        ..animationStyle = EasyLoadingAnimationStyle.scale;
      
      LoggerUtil.i('加载弹窗初始化完成');
    } catch (e) {
      LoggerUtil.e('加载弹窗初始化失败: $e');
    }
  }
  
  /// 显示加载弹窗
  static void show([String? status]) {
    try {
      EasyLoading.show(status: status ?? '加载中...');
      LoggerUtil.d('显示加载弹窗: ${status ?? '加载中...'}');
    } catch (e) {
      LoggerUtil.e('显示加载弹窗失败: $e');
    }
  }
  
  /// 显示进度弹窗
  static void showProgress(
    double progress, {
    String? status,
  }) {
    try {
      EasyLoading.showProgress(
        progress,
        status: status ?? '${(progress * 100).toInt()}%',
      );
      LoggerUtil.d('显示进度弹窗: ${(progress * 100).toInt()}%');
    } catch (e) {
      LoggerUtil.e('显示进度弹窗失败: $e');
    }
  }
  
  /// 显示成功弹窗
  static void showSuccess(
    String status, {
    Duration? duration,
  }) {
    try {
      EasyLoading.showSuccess(
        status,
        duration: duration ?? const Duration(seconds: 2),
      );
      LoggerUtil.d('显示成功弹窗: $status');
    } catch (e) {
      LoggerUtil.e('显示成功弹窗失败: $e');
    }
  }
  
  /// 显示错误弹窗
  static void showError(
    String status, {
    Duration? duration,
  }) {
    try {
      EasyLoading.showError(
        status,
        duration: duration ?? const Duration(seconds: 3),
      );
      LoggerUtil.d('显示错误弹窗: $status');
    } catch (e) {
      LoggerUtil.e('显示错误弹窗失败: $e');
    }
  }
  
  /// 显示信息弹窗
  static void showInfo(
    String status, {
    Duration? duration,
  }) {
    try {
      EasyLoading.showInfo(
        status,
        duration: duration ?? const Duration(seconds: 2),
      );
      LoggerUtil.d('显示信息弹窗: $status');
    } catch (e) {
      LoggerUtil.e('显示信息弹窗失败: $e');
    }
  }
  
  /// 显示提示弹窗
  static void showToast(
    String status, {
    Duration? duration,
  }) {
    try {
      EasyLoading.showToast(
        status,
        duration: duration ?? const Duration(seconds: 2),
      );
      LoggerUtil.d('显示提示弹窗: $status');
    } catch (e) {
      LoggerUtil.e('显示提示弹窗失败: $e');
    }
  }
  
  /// 隐藏弹窗
  static void dismiss() {
    try {
      EasyLoading.dismiss();
      LoggerUtil.d('隐藏弹窗');
    } catch (e) {
      LoggerUtil.e('隐藏弹窗失败: $e');
    }
  }
  
  /// 检查是否正在显示
  static bool get isShow => EasyLoading.isShow;
  
  /// 设置浅色主题
  static void setLightTheme() {
    try {
      EasyLoading.instance
        ..backgroundColor = Colors.white
        ..textColor = AppTheme.textPrimaryLight
        ..indicatorColor = AppTheme.primaryColor
        ..progressColor = AppTheme.primaryColor;
      LoggerUtil.d('设置加载弹窗浅色主题');
    } catch (e) {
      LoggerUtil.e('设置加载弹窗浅色主题失败: $e');
    }
  }
  
  /// 设置深色主题
  static void setDarkTheme() {
    try {
      EasyLoading.instance
        ..backgroundColor = AppTheme.surfaceDark
        ..textColor = AppTheme.textPrimaryDark
        ..indicatorColor = AppTheme.primaryColor
        ..progressColor = AppTheme.primaryColor;
      LoggerUtil.d('设置加载弹窗深色主题');
    } catch (e) {
      LoggerUtil.e('设置加载弹窗深色主题失败: $e');
    }
  }
}

/// 自定义加载弹窗
class CustomLoadingDialog extends StatelessWidget {
  final String? message;
  final bool showProgress;
  final double? progress;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? indicatorColor;
  
  const CustomLoadingDialog({
    Key? key,
    this.message,
    this.showProgress = false,
    this.progress,
    this.backgroundColor,
    this.textColor,
    this.indicatorColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(ScreenAdapter.w(20)),
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(ScreenAdapter.r(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 加载指示器
            if (showProgress && progress != null)
              CircularProgressIndicator(
                value: progress,
                color: indicatorColor ?? Theme.of(context).primaryColor,
                strokeWidth: 3,
              )
            else
              CircularProgressIndicator(
                color: indicatorColor ?? Theme.of(context).primaryColor,
                strokeWidth: 3,
              ),
            
            if (message != null) ..[
              SizedBox(height: ScreenAdapter.h(16)),
              Text(
                message!,
                style: TextStyle(
                  fontSize: ScreenAdapter.sp(14),
                  color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            if (showProgress && progress != null) ..[
              SizedBox(height: ScreenAdapter.h(8)),
              Text(
                '${(progress! * 100).toInt()}%',
                style: TextStyle(
                  fontSize: ScreenAdapter.sp(12),
                  color: textColor ?? Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 显示自定义加载弹窗
  static void show(
    BuildContext context, {
    String? message,
    bool showProgress = false,
    double? progress,
    Color? backgroundColor,
    Color? textColor,
    Color? indicatorColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomLoadingDialog(
        message: message,
        showProgress: showProgress,
        progress: progress,
        backgroundColor: backgroundColor,
        textColor: textColor,
        indicatorColor: indicatorColor,
      ),
    );
  }
}

/// 消息弹窗
class MessageDialog {
  /// 显示确认弹窗
  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    Color? cancelColor,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: ScreenAdapter.sp(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            fontSize: ScreenAdapter.sp(14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText ?? '取消',
              style: TextStyle(
                color: cancelColor ?? Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText ?? '确认',
              style: TextStyle(
                color: confirmColor ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 显示警告弹窗
  static Future<void> showAlert(
    BuildContext context, {
    required String title,
    required String content,
    String? buttonText,
    Color? buttonColor,
  }) async {
    return await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: ScreenAdapter.sp(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            fontSize: ScreenAdapter.sp(14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              buttonText ?? '确定',
              style: TextStyle(
                color: buttonColor ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 显示输入弹窗
  static Future<String?> showInput(
    BuildContext context, {
    required String title,
    String? hint,
    String? initialValue,
    String? confirmText,
    String? cancelText,
    TextInputType? keyboardType,
    int? maxLength,
  }) async {
    final controller = TextEditingController(text: initialValue);
    
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: ScreenAdapter.sp(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          keyboardType: keyboardType,
          maxLength: maxLength,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              cancelText ?? '取消',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(
              confirmText ?? '确认',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 显示选择弹窗
  static Future<int?> showChoice(
    BuildContext context, {
    required String title,
    required List<String> options,
    int? selectedIndex,
  }) async {
    return await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: ScreenAdapter.sp(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return ListTile(
              title: Text(option),
              leading: Radio<int>(
                value: index,
                groupValue: selectedIndex,
                onChanged: (value) => Navigator.of(context).pop(value),
              ),
              onTap: () => Navigator.of(context).pop(index),
            );
          }).toList(),
        ),
      ),
    );
  }
}