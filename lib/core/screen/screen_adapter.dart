import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_mvvm/core/utils/logger_util.dart';

/// 屏幕适配管理器
/// 提供多屏幕尺寸的响应式布局支持
class ScreenAdapter {
  static final ScreenAdapter _instance = ScreenAdapter._internal();
  static ScreenAdapter get instance => _instance;
  
  ScreenAdapter._internal();
  
  /// 初始化屏幕适配
  static Future<void> init({
    Size designSize = const Size(375, 812), // iPhone X 设计尺寸
    bool splitScreenMode = false,
    double minTextAdapt = 0,
    double maxTextAdapt = double.infinity,
  }) async {
    try {
      await ScreenUtil.ensureScreenSize();
      LoggerUtil.i('屏幕适配初始化完成，设计尺寸: $designSize');
    } catch (e) {
      LoggerUtil.e('屏幕适配初始化失败: $e');
    }
  }
  
  /// 获取屏幕宽度
  static double get screenWidth => ScreenUtil().screenWidth;
  
  /// 获取屏幕高度
  static double get screenHeight => ScreenUtil().screenHeight;
  
  /// 获取状态栏高度
  static double get statusBarHeight => ScreenUtil().statusBarHeight;
  
  /// 获取底部安全区域高度
  static double get bottomBarHeight => ScreenUtil().bottomBarHeight;
  
  /// 获取设备像素比
  static double get pixelRatio => ScreenUtil().pixelRatio;
  
  /// 根据设计稿宽度适配
  static double w(num width) => ScreenUtil().setWidth(width);
  
  /// 根据设计稿高度适配
  static double h(num height) => ScreenUtil().setHeight(height);
  
  /// 根据宽度或高度中的较小值进行适配
  static double r(num radius) => ScreenUtil().radius(radius);
  
  /// 字体大小适配
  static double sp(num fontSize) => ScreenUtil().setSp(fontSize);
  
  /// 获取屏幕方向
  static Orientation get orientation => ScreenUtil().orientation;
  
  /// 是否为横屏
  static bool get isLandscape => orientation == Orientation.landscape;
  
  /// 是否为竖屏
  static bool get isPortrait => orientation == Orientation.portrait;
  
  /// 获取屏幕类型
  static ScreenType get screenType {
    final width = screenWidth;
    if (width < 600) {
      return ScreenType.mobile;
    } else if (width < 1024) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }
  
  /// 是否为手机屏幕
  static bool get isMobile => screenType == ScreenType.mobile;
  
  /// 是否为平板屏幕
  static bool get isTablet => screenType == ScreenType.tablet;
  
  /// 是否为桌面屏幕
  static bool get isDesktop => screenType == ScreenType.desktop;
  
  /// 获取安全区域内边距
  static EdgeInsets get safeAreaPadding {
    return EdgeInsets.only(
      top: statusBarHeight,
      bottom: bottomBarHeight,
    );
  }
  
  /// 获取响应式列数
  static int getResponsiveColumns() {
    switch (screenType) {
      case ScreenType.mobile:
        return isPortrait ? 1 : 2;
      case ScreenType.tablet:
        return isPortrait ? 2 : 3;
      case ScreenType.desktop:
        return isPortrait ? 3 : 4;
    }
  }
  
  /// 获取响应式间距
  static double getResponsiveSpacing() {
    switch (screenType) {
      case ScreenType.mobile:
        return w(16);
      case ScreenType.tablet:
        return w(20);
      case ScreenType.desktop:
        return w(24);
    }
  }
  
  /// 获取响应式字体大小
  static double getResponsiveFontSize(double baseFontSize) {
    switch (screenType) {
      case ScreenType.mobile:
        return sp(baseFontSize);
      case ScreenType.tablet:
        return sp(baseFontSize * 1.1);
      case ScreenType.desktop:
        return sp(baseFontSize * 1.2);
    }
  }
  
  /// 获取响应式图标大小
  static double getResponsiveIconSize(double baseIconSize) {
    switch (screenType) {
      case ScreenType.mobile:
        return r(baseIconSize);
      case ScreenType.tablet:
        return r(baseIconSize * 1.2);
      case ScreenType.desktop:
        return r(baseIconSize * 1.4);
    }
  }
  
  /// 获取响应式按钮高度
  static double getResponsiveButtonHeight() {
    switch (screenType) {
      case ScreenType.mobile:
        return h(48);
      case ScreenType.tablet:
        return h(52);
      case ScreenType.desktop:
        return h(56);
    }
  }
  
  /// 获取响应式卡片边距
  static EdgeInsets getResponsiveCardMargin() {
    final spacing = getResponsiveSpacing();
    return EdgeInsets.all(spacing);
  }
  
  /// 获取响应式卡片内边距
  static EdgeInsets getResponsiveCardPadding() {
    switch (screenType) {
      case ScreenType.mobile:
        return EdgeInsets.all(w(16));
      case ScreenType.tablet:
        return EdgeInsets.all(w(20));
      case ScreenType.desktop:
        return EdgeInsets.all(w(24));
    }
  }
  
  /// 获取响应式AppBar高度
  static double getResponsiveAppBarHeight() {
    switch (screenType) {
      case ScreenType.mobile:
        return kToolbarHeight;
      case ScreenType.tablet:
        return kToolbarHeight + h(8);
      case ScreenType.desktop:
        return kToolbarHeight + h(16);
    }
  }
  
  /// 获取响应式底部导航栏高度
  static double getResponsiveBottomNavHeight() {
    switch (screenType) {
      case ScreenType.mobile:
        return kBottomNavigationBarHeight;
      case ScreenType.tablet:
        return kBottomNavigationBarHeight + h(8);
      case ScreenType.desktop:
        return kBottomNavigationBarHeight + h(16);
    }
  }
  
  /// 获取屏幕信息
  static Map<String, dynamic> getScreenInfo() {
    return {
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'statusBarHeight': statusBarHeight,
      'bottomBarHeight': bottomBarHeight,
      'pixelRatio': pixelRatio,
      'orientation': orientation.toString(),
      'screenType': screenType.toString(),
      'isLandscape': isLandscape,
      'isPortrait': isPortrait,
      'isMobile': isMobile,
      'isTablet': isTablet,
      'isDesktop': isDesktop,
    };
  }
}

/// 屏幕类型枚举
enum ScreenType {
  mobile,   // 手机
  tablet,   // 平板
  desktop,  // 桌面
}

/// 响应式布局构建器
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveBuilder({
    Key? key,
    required this.builder,
    this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final screenType = ScreenAdapter.screenType;
    
    // 如果提供了特定屏幕类型的Widget，优先使用
    switch (screenType) {
      case ScreenType.mobile:
        if (mobile != null) return mobile!;
        break;
      case ScreenType.tablet:
        if (tablet != null) return tablet!;
        break;
      case ScreenType.desktop:
        if (desktop != null) return desktop!;
        break;
    }
    
    // 否则使用builder
    return builder(context, screenType);
  }
}

/// 响应式网格布局
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final EdgeInsets? padding;
  
  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.padding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final screenType = ScreenAdapter.screenType;
    
    int columns;
    switch (screenType) {
      case ScreenType.mobile:
        columns = mobileColumns ?? 1;
        break;
      case ScreenType.tablet:
        columns = tabletColumns ?? 2;
        break;
      case ScreenType.desktop:
        columns = desktopColumns ?? 3;
        break;
    }
    
    return Padding(
      padding: padding ?? ScreenAdapter.getResponsiveCardPadding(),
      child: GridView.count(
        crossAxisCount: columns,
        crossAxisSpacing: spacing ?? ScreenAdapter.getResponsiveSpacing(),
        mainAxisSpacing: runSpacing ?? ScreenAdapter.getResponsiveSpacing(),
        children: children,
      ),
    );
  }
}

/// 响应式文本
class ResponsiveText extends StatelessWidget {
  final String text;
  final double baseFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  
  const ResponsiveText(
    this.text, {
    Key? key,
    this.baseFontSize = 14,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: ScreenAdapter.getResponsiveFontSize(baseFontSize),
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// 响应式图标
class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final double baseSize;
  final Color? color;
  
  const ResponsiveIcon(
    this.icon, {
    Key? key,
    this.baseSize = 24,
    this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: ScreenAdapter.getResponsiveIconSize(baseSize),
      color: color,
    );
  }
}

/// 响应式按钮
class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  
  const ResponsiveButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: ScreenAdapter.getResponsiveButtonHeight(),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
        ),
        child: ResponsiveText(
          text,
          baseFontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}