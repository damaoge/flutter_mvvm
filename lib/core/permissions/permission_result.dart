import 'package:permission_handler/permission_handler.dart';

/// 权限请求结果
class PermissionResult {
  final Permission? permission;
  final PermissionResultStatus status;
  final String message;
  
  PermissionResult({
    required this.permission,
    required this.status,
    required this.message,
  });
  
  /// 是否已授予权限
  bool get isGranted => status == PermissionResultStatus.granted;
  
  /// 是否被拒绝
  bool get isDenied => status == PermissionResultStatus.denied;
  
  /// 是否被永久拒绝
  bool get isPermanentlyDenied => status == PermissionResultStatus.permanentlyDenied;
  
  /// 是否受限
  bool get isRestricted => status == PermissionResultStatus.restricted;
  
  /// 是否为临时权限
  bool get isProvisional => status == PermissionResultStatus.provisional;
  
  /// 是否为有限权限
  bool get isLimited => status == PermissionResultStatus.limited;
  
  /// 是否发生错误
  bool get hasError => status == PermissionResultStatus.error;
  
  /// 是否需要用户手动设置
  bool get needsManualSetting => isPermanentlyDenied || isRestricted;
  
  /// 是否可以重新请求
  bool get canRetry => isDenied && !isPermanentlyDenied;
  
  /// 获取用户友好的状态描述
  String get userFriendlyMessage {
    switch (status) {
      case PermissionResultStatus.granted:
        return '权限已获得';
      case PermissionResultStatus.denied:
        return '权限被拒绝，请重新授权';
      case PermissionResultStatus.permanentlyDenied:
        return '权限被永久拒绝，请前往设置页面手动开启';
      case PermissionResultStatus.restricted:
        return '权限受到系统限制';
      case PermissionResultStatus.limited:
        return '权限部分开启';
      case PermissionResultStatus.provisional:
        return '临时权限已获得';
      case PermissionResultStatus.error:
        return '权限检查出现错误';
    }
  }
  
  /// 获取权限名称
  String get permissionName {
    if (permission == null) return '未知权限';
    
    switch (permission!) {
      case Permission.camera:
        return '相机';
      case Permission.microphone:
        return '麦克风';
      case Permission.storage:
        return '存储';
      case Permission.photos:
        return '相册';
      case Permission.location:
        return '位置';
      case Permission.locationAlways:
        return '始终位置';
      case Permission.locationWhenInUse:
        return '使用时位置';
      case Permission.notification:
        return '通知';
      case Permission.contacts:
        return '通讯录';
      case Permission.calendar:
        return '日历';
      case Permission.bluetooth:
        return '蓝牙';
      case Permission.bluetoothScan:
        return '蓝牙扫描';
      case Permission.bluetoothAdvertise:
        return '蓝牙广播';
      case Permission.bluetoothConnect:
        return '蓝牙连接';
      default:
        return permission.toString();
    }
  }
  
  @override
  String toString() {
    return 'PermissionResult{permission: $permission, status: $status, message: $message}';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PermissionResult &&
        other.permission == permission &&
        other.status == status &&
        other.message == message;
  }
  
  @override
  int get hashCode => Object.hash(permission, status, message);
}

/// 权限结果状态
enum PermissionResultStatus {
  /// 已授予
  granted,
  
  /// 被拒绝
  denied,
  
  /// 受限
  restricted,
  
  /// 有限权限（iOS）
  limited,
  
  /// 永久拒绝
  permanentlyDenied,
  
  /// 临时权限（iOS）
  provisional,
  
  /// 错误
  error,
}

/// 权限结果状态扩展
extension PermissionResultStatusExtension on PermissionResultStatus {
  /// 获取状态名称
  String get name {
    switch (this) {
      case PermissionResultStatus.granted:
        return '已授予';
      case PermissionResultStatus.denied:
        return '被拒绝';
      case PermissionResultStatus.restricted:
        return '受限';
      case PermissionResultStatus.limited:
        return '有限权限';
      case PermissionResultStatus.permanentlyDenied:
        return '永久拒绝';
      case PermissionResultStatus.provisional:
        return '临时权限';
      case PermissionResultStatus.error:
        return '错误';
    }
  }
  
  /// 获取状态描述
  String get description {
    switch (this) {
      case PermissionResultStatus.granted:
        return '用户已授予该权限';
      case PermissionResultStatus.denied:
        return '用户拒绝了该权限，但可以重新请求';
      case PermissionResultStatus.restricted:
        return '权限受到系统限制，无法使用';
      case PermissionResultStatus.limited:
        return '权限部分开启（仅iOS）';
      case PermissionResultStatus.permanentlyDenied:
        return '用户永久拒绝了该权限，需要手动在设置中开启';
      case PermissionResultStatus.provisional:
        return '临时权限已获得（仅iOS）';
      case PermissionResultStatus.error:
        return '权限检查过程中发生错误';
    }
  }
  
  /// 是否为成功状态
  bool get isSuccess => this == PermissionResultStatus.granted || 
                       this == PermissionResultStatus.provisional ||
                       this == PermissionResultStatus.limited;
  
  /// 是否为失败状态
  bool get isFailure => !isSuccess && this != PermissionResultStatus.error;
  
  /// 是否为错误状态
  bool get isError => this == PermissionResultStatus.error;
}