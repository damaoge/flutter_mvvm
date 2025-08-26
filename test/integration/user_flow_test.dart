import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_mvvm/main.dart' as app;
import '../test_helpers/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('用户流程集成测试', () {
    testWidgets('完整的用户注册和登录流程', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle();

      // 等待启动页面加载完成
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 验证是否显示登录页面（假设未登录时显示登录页面）
      expect(find.text('登录'), findsOneWidget);

      // 点击注册按钮
      final registerButton = find.text('注册');
      if (registerButton.evaluate().isNotEmpty) {
        await tester.tap(registerButton);
        await tester.pumpAndSettle();
      }

      // 填写注册表单
      await tester.enterText(find.byType(TextField).at(0), TestConstants.testUserName);
      await tester.enterText(find.byType(TextField).at(1), TestConstants.testEmail);
      await tester.enterText(find.byType(TextField).at(2), TestConstants.testPassword);
      await tester.pumpAndSettle();

      // 提交注册表单
      final submitButton = find.text('注册').last;
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // 等待注册完成并跳转到主页
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 验证是否成功跳转到主页
      expect(find.text('首页'), findsOneWidget);
      expect(find.text(TestConstants.testUserName), findsOneWidget);

      // 测试主页功能
      await _testHomePageFeatures(tester);

      // 测试注销功能
      await _testLogoutFlow(tester);

      // 测试登录功能
      await _testLoginFlow(tester);
    });

    testWidgets('主题切换功能测试', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle();

      // 等待应用加载完成
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 查找主题切换按钮
      final themeToggleButton = find.byIcon(Icons.brightness_6);
      if (themeToggleButton.evaluate().isNotEmpty) {
        // 获取当前主题
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        final currentBrightness = materialApp.theme?.brightness ?? Brightness.light;

        // 点击主题切换按钮
        await tester.tap(themeToggleButton);
        await tester.pumpAndSettle();

        // 验证主题是否切换
        final updatedMaterialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        final newBrightness = updatedMaterialApp.theme?.brightness ?? Brightness.light;
        
        expect(newBrightness, isNot(equals(currentBrightness)));
      }
    });

    testWidgets('语言切换功能测试', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle();

      // 等待应用加载完成
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 查找语言切换按钮
      final languageToggleButton = find.byIcon(Icons.language);
      if (languageToggleButton.evaluate().isNotEmpty) {
        // 点击语言切换按钮
        await tester.tap(languageToggleButton);
        await tester.pumpAndSettle();

        // 验证语言是否切换（这里需要根据实际的本地化实现来验证）
        // 例如，检查某些文本是否从中文变为英文或反之
      }
    });

    testWidgets('网络错误处理测试', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle();

      // 模拟网络错误情况
      // 这里需要根据实际的网络层实现来模拟错误
      
      // 尝试执行需要网络的操作
      final refreshButton = find.byIcon(Icons.refresh);
      if (refreshButton.evaluate().isNotEmpty) {
        await tester.tap(refreshButton);
        await tester.pumpAndSettle();

        // 验证是否显示错误信息
        expect(find.textContaining('网络'), findsWidgets);
      }
    });
  });
}

/// 测试主页功能
Future<void> _testHomePageFeatures(WidgetTester tester) async {
  // 测试计数器功能
  final incrementButton = find.byIcon(Icons.add);
  if (incrementButton.evaluate().isNotEmpty) {
    // 点击增加按钮
    await tester.tap(incrementButton);
    await tester.pumpAndSettle();

    // 验证计数器是否增加
    expect(find.text('1'), findsOneWidget);

    // 再次点击
    await tester.tap(incrementButton);
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
  }

  // 测试重置按钮
  final resetButton = find.text('重置');
  if (resetButton.evaluate().isNotEmpty) {
    await tester.tap(resetButton);
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
  }

  // 测试导航到设置页面
  final settingsButton = find.text('设置');
  if (settingsButton.evaluate().isNotEmpty) {
    await tester.tap(settingsButton);
    await tester.pumpAndSettle();

    // 验证是否跳转到设置页面
    expect(find.text('设置'), findsOneWidget);

    // 返回主页
    final backButton = find.byIcon(Icons.arrow_back);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }
  }

  // 测试导航到个人资料页面
  final profileButton = find.text('个人资料');
  if (profileButton.evaluate().isNotEmpty) {
    await tester.tap(profileButton);
    await tester.pumpAndSettle();

    // 验证是否跳转到个人资料页面
    expect(find.text('个人资料'), findsOneWidget);

    // 返回主页
    final backButton = find.byIcon(Icons.arrow_back);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }
  }
}

/// 测试注销流程
Future<void> _testLogoutFlow(WidgetTester tester) async {
  // 查找注销按钮
  final logoutButton = find.text('注销');
  if (logoutButton.evaluate().isNotEmpty) {
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // 验证是否返回到登录页面
    expect(find.text('登录'), findsOneWidget);
  }
}

/// 测试登录流程
Future<void> _testLoginFlow(WidgetTester tester) async {
  // 填写登录表单
  await tester.enterText(find.byType(TextField).at(0), TestConstants.testEmail);
  await tester.enterText(find.byType(TextField).at(1), TestConstants.testPassword);
  await tester.pumpAndSettle();

  // 点击登录按钮
  final loginButton = find.text('登录').last;
  await tester.tap(loginButton);
  await tester.pumpAndSettle();

  // 等待登录完成
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // 验证是否成功登录并跳转到主页
  expect(find.text('首页'), findsOneWidget);
}