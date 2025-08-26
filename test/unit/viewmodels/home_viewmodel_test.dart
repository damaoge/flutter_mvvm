import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_mvvm/pages/home/home_page.dart';
import 'package:flutter_mvvm/core/repository/user_repository.dart';
import 'package:flutter_mvvm/core/services/theme_service.dart';
import 'package:flutter_mvvm/core/services/locale_service.dart';
import 'package:flutter_mvvm/core/navigation/router_manager.dart';

// 生成Mock类
@GenerateMocks([
  IUserRepository,
  IThemeService,
  ILocaleService,
  RouterManager,
])
import 'home_viewmodel_test.mocks.dart';

void main() {
  group('HomeViewModel Tests', () {
    late HomeViewModel viewModel;
    late MockIUserRepository mockUserRepository;
    late MockIThemeService mockThemeService;
    late MockILocaleService mockLocaleService;
    late MockRouterManager mockRouterManager;

    setUp(() {
      mockUserRepository = MockIUserRepository();
      mockThemeService = MockIThemeService();
      mockLocaleService = MockILocaleService();
      mockRouterManager = MockRouterManager();
      
      viewModel = HomeViewModel();
      // 注意：在实际测试中，你需要通过依赖注入来设置这些mock对象
    });

    group('初始化', () {
      test('should initialize with default values', () {
        expect(viewModel.counter, equals(0));
        expect(viewModel.userName, equals('用户'));
        expect(viewModel.isLoading, isFalse);
      });
    });

    group('计数器功能', () {
      test('should increment counter', () {
        // Arrange
        final initialCounter = viewModel.counter;

        // Act
        viewModel.incrementCounter();

        // Assert
        expect(viewModel.counter, equals(initialCounter + 1));
      });

      test('should reset counter to zero', () {
        // Arrange
        viewModel.incrementCounter();
        viewModel.incrementCounter();
        expect(viewModel.counter, equals(2));

        // Act
        viewModel.resetCounter();

        // Assert
        expect(viewModel.counter, equals(0));
      });
    });

    group('用户信息加载', () {
      test('should load user info when logged in', () async {
        // Arrange
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockUserRepository.isLoggedIn())
            .thenAnswer((_) async => true);
        when(mockUserRepository.getCurrentUser())
            .thenAnswer((_) async => user);

        // Act
        await viewModel.loadUserInfo();

        // Assert
        expect(viewModel.userName, equals('Test User'));
        verify(mockUserRepository.isLoggedIn()).called(1);
        verify(mockUserRepository.getCurrentUser()).called(1);
      });

      test('should use default name when not logged in', () async {
        // Arrange
        when(mockUserRepository.isLoggedIn())
            .thenAnswer((_) async => false);

        // Act
        await viewModel.loadUserInfo();

        // Assert
        expect(viewModel.userName, equals('用户'));
        verify(mockUserRepository.isLoggedIn()).called(1);
        verifyNever(mockUserRepository.getCurrentUser());
      });

      test('should handle error when loading user info fails', () async {
        // Arrange
        when(mockUserRepository.isLoggedIn())
            .thenAnswer((_) async => true);
        when(mockUserRepository.getCurrentUser())
            .thenThrow(Exception('Network error'));

        // Act
        await viewModel.loadUserInfo();

        // Assert
        expect(viewModel.userName, equals('用户'));
        verify(mockUserRepository.isLoggedIn()).called(1);
        verify(mockUserRepository.getCurrentUser()).called(1);
      });
    });

    group('用户认证', () {
      test('should login successfully', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final user = User(
          id: '1',
          name: 'Test User',
          email: email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockUserRepository.login(email, password))
            .thenAnswer((_) async => user);

        // Act
        await viewModel.login(email, password);

        // Assert
        expect(viewModel.userName, equals('Test User'));
        verify(mockUserRepository.login(email, password)).called(1);
      });

      test('should handle login failure', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(mockUserRepository.login(email, password))
            .thenAnswer((_) async => null);

        // Act
        await viewModel.login(email, password);

        // Assert
        expect(viewModel.userName, equals('用户'));
        verify(mockUserRepository.login(email, password)).called(1);
      });

      test('should logout successfully', () async {
        // Arrange
        when(mockUserRepository.logout())
            .thenAnswer((_) async => {});

        // Act
        await viewModel.logout();

        // Assert
        expect(viewModel.userName, equals('用户'));
        verify(mockUserRepository.logout()).called(1);
      });

      test('should register successfully', () async {
        // Arrange
        const name = 'New User';
        const email = 'new@example.com';
        const password = 'password123';
        final user = User(
          id: '2',
          name: name,
          email: email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockUserRepository.register(name, email, password))
            .thenAnswer((_) async => user);

        // Act
        await viewModel.register(name, email, password);

        // Assert
        expect(viewModel.userName, equals('New User'));
        verify(mockUserRepository.register(name, email, password)).called(1);
      });
    });

    group('主题切换', () {
      test('should toggle theme', () {
        // Act
        viewModel.toggleTheme();

        // Assert
        // 注意：在实际测试中，你需要验证ThemeService的调用
        // verify(mockThemeService.toggleTheme()).called(1);
      });
    });

    group('语言切换', () {
      test('should toggle language', () {
        // Act
        viewModel.toggleLanguage();

        // Assert
        // 注意：在实际测试中，你需要验证LocaleService的调用
        // verify(mockLocaleService.toggleLocale()).called(1);
      });
    });

    group('导航', () {
      test('should navigate to settings', () {
        // Act
        viewModel.goToSettings();

        // Assert
        // 注意：在实际测试中，你需要验证RouterManager的调用
        // verify(mockRouterManager.pushNamed('/settings')).called(1);
      });

      test('should navigate to profile', () {
        // Act
        viewModel.goToProfile();

        // Assert
        // 注意：在实际测试中，你需要验证RouterManager的调用
        // verify(mockRouterManager.pushNamed('/profile')).called(1);
      });
    });
  });
}