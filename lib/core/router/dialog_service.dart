import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 对话框服务
/// 专门处理各种弹窗和对话框
class DialogService {
  static final DialogService _instance = DialogService._internal();
  static DialogService get instance => _instance;
  
  DialogService._internal();
  
  /// 显示底部弹窗
  Future<T?> showBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) async {
    try {
      LoggerUtil.d('显示底部弹窗');
      
      return await Get.bottomSheet<T>(
        child,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
      );
    } catch (e) {
      LoggerUtil.e('显示底部弹窗失败: $e');
      return null;
    }
  }
  
  /// 显示对话框
  Future<T?> showDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
  }) async {
    try {
      LoggerUtil.d('显示对话框');
      
      return await Get.dialog<T>(
        child,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        barrierLabel: barrierLabel,
      );
    } catch (e) {
      LoggerUtil.e('显示对话框失败: $e');
      return null;
    }
  }
  
  /// 显示确认对话框
  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = '确定',
    String cancelText = '取消',
    Color? confirmColor,
    Color? cancelColor,
  }) async {
    try {
      LoggerUtil.d('显示确认对话框: $title');
      
      return await Get.dialog<bool>(
        AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                cancelText,
                style: TextStyle(color: cancelColor),
              ),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(
                confirmText,
                style: TextStyle(color: confirmColor),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      LoggerUtil.e('显示确认对话框失败: $e');
      return null;
    }
  }
  
  /// 显示警告对话框
  Future<void> showAlertDialog({
    required String title,
    required String content,
    String buttonText = '确定',
    Color? buttonColor,
  }) async {
    try {
      LoggerUtil.d('显示警告对话框: $title');
      
      await Get.dialog(
        AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                buttonText,
                style: TextStyle(color: buttonColor),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      LoggerUtil.e('显示警告对话框失败: $e');
    }
  }
  
  /// 显示输入对话框
  Future<String?> showInputDialog({
    required String title,
    String? hint,
    String? initialValue,
    String confirmText = '确定',
    String cancelText = '取消',
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool obscureText = false,
  }) async {
    try {
      LoggerUtil.d('显示输入对话框: $title');
      
      final controller = TextEditingController(text: initialValue);
      
      final result = await Get.dialog<String>(
        AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
            keyboardType: keyboardType,
            maxLength: maxLength,
            obscureText: obscureText,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Get.back(result: controller.text),
              child: Text(confirmText),
            ),
          ],
        ),
      );
      
      controller.dispose();
      return result;
    } catch (e) {
      LoggerUtil.e('显示输入对话框失败: $e');
      return null;
    }
  }
  
  /// 显示选择对话框
  Future<T?> showChoiceDialog<T>({
    required String title,
    required List<DialogChoice<T>> choices,
    String cancelText = '取消',
  }) async {
    try {
      LoggerUtil.d('显示选择对话框: $title');
      
      return await Get.dialog<T>(
        AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: choices.map((choice) {
              return ListTile(
                title: Text(choice.title),
                subtitle: choice.subtitle != null ? Text(choice.subtitle!) : null,
                leading: choice.icon,
                onTap: () => Get.back(result: choice.value),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(cancelText),
            ),
          ],
        ),
      );
    } catch (e) {
      LoggerUtil.e('显示选择对话框失败: $e');
      return null;
    }
  }
  
  /// 显示Snackbar
  void showSnackbar({
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Color? backgroundColor,
    Color? colorText,
    Widget? icon,
    bool isDismissible = true,
    DismissDirection? dismissDirection,
    VoidCallback? onTap,
  }) {
    try {
      LoggerUtil.d('显示Snackbar: $message');
      
      Get.snackbar(
        title ?? '',
        message,
        duration: duration,
        snackPosition: snackPosition,
        backgroundColor: backgroundColor,
        colorText: colorText,
        icon: icon,
        isDismissible: isDismissible,
        dismissDirection: dismissDirection,
        onTap: onTap != null ? (_) => onTap() : null,
      );
    } catch (e) {
      LoggerUtil.e('显示Snackbar失败: $e');
    }
  }
  
  /// 关闭所有对话框
  void closeAllDialogs() {
    try {
      if (Get.isDialogOpen ?? false) {
        Get.until((route) => !Get.isDialogOpen!);
        LoggerUtil.d('关闭所有对话框');
      }
    } catch (e) {
      LoggerUtil.e('关闭所有对话框失败: $e');
    }
  }
  
  /// 关闭所有底部弹窗
  void closeAllBottomSheets() {
    try {
      if (Get.isBottomSheetOpen ?? false) {
        Get.until((route) => !Get.isBottomSheetOpen!);
        LoggerUtil.d('关闭所有底部弹窗');
      }
    } catch (e) {
      LoggerUtil.e('关闭所有底部弹窗失败: $e');
    }
  }
  
  /// 关闭所有Snackbar
  void closeAllSnackbars() {
    try {
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
        LoggerUtil.d('关闭所有Snackbar');
      }
    } catch (e) {
      LoggerUtil.e('关闭所有Snackbar失败: $e');
    }
  }
}

/// 对话框选择项
class DialogChoice<T> {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final T value;
  
  const DialogChoice({
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
  });
}