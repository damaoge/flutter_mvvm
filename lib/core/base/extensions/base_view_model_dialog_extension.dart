import 'package:flutter/material.dart';
import 'package:flutter_mvvm/core/base/base_view_model.dart';
import 'package:flutter_mvvm/core/router/router_manager.dart';

/// BaseViewModel弹窗和提示扩展
/// 提供统一的对话框和提示功能
extension BaseViewModelDialogExtension on BaseViewModel {
  /// 显示成功提示
  void showSuccess(String message, {String? title}) {
    RouterManager.instance.dialog.showSnackbar(
      message: message,
      title: title ?? '成功',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// 显示错误提示
  void showError(String message, {String? title}) {
    RouterManager.instance.dialog.showSnackbar(
      message: message,
      title: title ?? '错误',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  /// 显示警告提示
  void showWarning(String message, {String? title}) {
    RouterManager.instance.dialog.showSnackbar(
      message: message,
      title: title ?? '警告',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }

  /// 显示信息提示
  void showInfo(String message, {String? title}) {
    RouterManager.instance.dialog.showSnackbar(
      message: message,
      title: title ?? '提示',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  /// 显示普通提示
  void showMessage(String message, {String? title}) {
    RouterManager.instance.dialog.showSnackbar(
      message: message,
      title: title,
    );
  }

  /// 显示确认对话框
  Future<bool?> showConfirm({
    required String title,
    required String content,
    String confirmText = '确定',
    String cancelText = '取消',
  }) async {
    return await RouterManager.instance.dialog.showConfirmDialog(
      title: title,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  /// 显示警告对话框
  Future<void> showAlert({
    required String title,
    required String content,
    String buttonText = '确定',
  }) async {
    await RouterManager.instance.dialog.showAlertDialog(
      title: title,
      content: content,
      buttonText: buttonText,
    );
  }

  /// 显示输入对话框
  Future<String?> showInput({
    required String title,
    String? hint,
    String? initialValue,
    String confirmText = '确定',
    String cancelText = '取消',
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) async {
    return await RouterManager.instance.dialog.showInputDialog(
      title: title,
      hint: hint,
      initialValue: initialValue,
      confirmText: confirmText,
      cancelText: cancelText,
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }

  /// 显示底部弹窗
  Future<T?> showBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    return await RouterManager.instance.dialog.showBottomSheet<T>(
      child: child,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  /// 显示自定义对话框
  Future<T?> showCustomDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) async {
    return await RouterManager.instance.dialog.showDialog<T>(
      child: child,
      barrierDismissible: barrierDismissible,
    );
  }
}