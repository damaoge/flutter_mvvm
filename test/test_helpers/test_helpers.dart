import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mvvm/core/providers/theme_provider.dart';
import 'package:flutter_mvvm/core/providers/locale_provider.dart';

/// 测试辅助工具类
class TestHelpers {
  /// 创建测试用的Widget包装器
  static Widget createTestableWidget({
    required Widget child,
    ThemeProvider? themeProvider,
    LocaleProvider? localeProvider,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider ?? ThemeProvider(),
        ),
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => localeProvider ?? LocaleProvider(),
        ),
      ],
      child: MaterialApp(
        home: child,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
      ),
    );
  }

  /// 等待所有异步操作完成
  static Future<void> pumpAndSettle(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  /// 查找文本Widget
  static Finder findText(String text) {
    return find.text(text);
  }

  /// 查找按钮Widget
  static Finder findButton(String text) {
    return find.widgetWithText(ElevatedButton, text);
  }

  /// 查找图标按钮
  static Finder findIconButton(IconData icon) {
    return find.widgetWithIcon(IconButton, icon);
  }

  /// 点击Widget
  static Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// 输入文本
  static Future<void> enterText(WidgetTester tester, Finder finder, String text) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// 验证Widget是否存在
  static void expectWidgetExists(Finder finder) {
    expect(finder, findsOneWidget);
  }

  /// 验证Widget是否不存在
  static void expectWidgetNotExists(Finder finder) {
    expect(finder, findsNothing);
  }

  /// 验证文本是否存在
  static void expectTextExists(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// 验证文本是否不存在
  static void expectTextNotExists(String text) {
    expect(find.text(text), findsNothing);
  }

  /// 创建Mock对象的通用方法
  static T createMock<T extends Object>() {
    return Mock() as T;
  }

  /// 设置Mock方法的返回值
  static void setupMockReturn<T>(T mock, Function method, dynamic returnValue) {
    when(method).thenReturn(returnValue);
  }

  /// 设置Mock异步方法的返回值
  static void setupMockAsyncReturn<T>(T mock, Function method, dynamic returnValue) {
    when(method).thenAnswer((_) async => returnValue);
  }

  /// 验证Mock方法是否被调用
  static void verifyMethodCalled(dynamic mock, Function method, [int times = 1]) {
    verify(method).called(times);
  }

  /// 验证Mock方法从未被调用
  static void verifyMethodNeverCalled(dynamic mock, Function method) {
    verifyNever(method);
  }

  /// 创建测试用的DateTime
  static DateTime createTestDateTime([int? year, int? month, int? day]) {
    return DateTime(
      year ?? 2024,
      month ?? 1,
      day ?? 1,
      12, // hour
      0,  // minute
      0,  // second
    );
  }

  /// 创建测试用的用户数据
  static Map<String, dynamic> createTestUserData({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return {
      'id': id ?? '1',
      'name': name ?? 'Test User',
      'email': email ?? 'test@example.com',
      'createdAt': (createdAt ?? now).toIso8601String(),
      'updatedAt': (updatedAt ?? now).toIso8601String(),
    };
  }

  /// 创建测试用的产品数据
  static Map<String, dynamic> createTestProductData({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return {
      'id': id ?? '1',
      'name': name ?? 'Test Product',
      'description': description ?? 'Test product description',
      'price': price ?? 99.99,
      'category': category ?? 'electronics',
      'createdAt': (createdAt ?? now).toIso8601String(),
      'updatedAt': (updatedAt ?? now).toIso8601String(),
    };
  }

  /// 等待指定时间
  static Future<void> wait(Duration duration) async {
    await Future.delayed(duration);
  }

  /// 打印调试信息（仅在测试环境中）
  static void debugPrint(String message) {
    if (kDebugMode) {
      print('[TEST DEBUG] $message');
    }
  }

  /// 验证异常是否被抛出
  static void expectException<T extends Exception>(Function function) {
    expect(() => function(), throwsA(isA<T>()));
  }

  /// 验证异步异常是否被抛出
  static void expectAsyncException<T extends Exception>(Future Function() function) {
    expect(() => function(), throwsA(isA<T>()));
  }

  /// 创建测试用的HTTP响应数据
  static Map<String, dynamic> createHttpResponse({
    int? statusCode,
    dynamic data,
    String? message,
  }) {
    return {
      'statusCode': statusCode ?? 200,
      'data': data,
      'message': message ?? 'Success',
    };
  }

  /// 创建测试用的错误响应
  static Map<String, dynamic> createErrorResponse({
    int? statusCode,
    String? message,
    String? error,
  }) {
    return {
      'statusCode': statusCode ?? 400,
      'message': message ?? 'Bad Request',
      'error': error ?? 'Validation failed',
    };
  }
}

/// 测试常量
class TestConstants {
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'password123';
  static const String testUserName = 'Test User';
  static const String testUserId = '1';
  
  static const String testProductName = 'Test Product';
  static const String testProductId = '1';
  static const double testProductPrice = 99.99;
  
  static const Duration shortDelay = Duration(milliseconds: 100);
  static const Duration mediumDelay = Duration(milliseconds: 500);
  static const Duration longDelay = Duration(seconds: 1);
  
  static const String apiBaseUrl = 'https://api.test.com';
  static const String testToken = 'test_token_123';
}

/// 测试匹配器
class TestMatchers {
  /// 匹配包含特定文本的Widget
  static Matcher containsText(String text) {
    return findsWidgetWithText(text);
  }
  
  /// 匹配特定类型的异常
  static Matcher isExceptionOfType<T>() {
    return isA<T>();
  }
  
  /// 匹配空列表
  static Matcher get isEmptyList => isEmpty;
  
  /// 匹配非空列表
  static Matcher get isNotEmptyList => isNotEmpty;
}

/// 自定义匹配器函数
Matcher findsWidgetWithText(String text) {
  return find.text(text);
}