import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_mvvm/core/repository/user_repository.dart';
import 'package:flutter_mvvm/core/services/auth_service.dart';

// 生成Mock类
@GenerateMocks([IAuthService])
import 'user_repository_test.mocks.dart';

void main() {
  group('UserRepository Tests', () {
    late UserRepository userRepository;
    late MockIAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockIAuthService();
      userRepository = UserRepository(mockAuthService);
    });

    group('login', () {
      test('should return user when login is successful', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        final expectedUser = User(
          id: '1',
          name: 'Test User',
          email: email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockAuthService.login(email, password))
            .thenAnswer((_) async => expectedUser);

        // Act
        final result = await userRepository.login(email, password);

        // Assert
        expect(result, equals(expectedUser));
        verify(mockAuthService.login(email, password)).called(1);
      });

      test('should return null when login fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(mockAuthService.login(email, password))
            .thenAnswer((_) async => null);

        // Act
        final result = await userRepository.login(email, password);

        // Assert
        expect(result, isNull);
        verify(mockAuthService.login(email, password)).called(1);
      });

      test('should throw exception when auth service throws', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockAuthService.login(email, password))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => userRepository.login(email, password),
          throwsException,
        );
      });
    });

    group('register', () {
      test('should return user when registration is successful', () async {
        // Arrange
        const name = 'Test User';
        const email = 'test@example.com';
        const password = 'password123';
        final expectedUser = User(
          id: '1',
          name: name,
          email: email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockAuthService.register(name, email, password))
            .thenAnswer((_) async => expectedUser);

        // Act
        final result = await userRepository.register(name, email, password);

        // Assert
        expect(result, equals(expectedUser));
        verify(mockAuthService.register(name, email, password)).called(1);
      });

      test('should return null when registration fails', () async {
        // Arrange
        const name = 'Test User';
        const email = 'test@example.com';
        const password = 'password123';

        when(mockAuthService.register(name, email, password))
            .thenAnswer((_) async => null);

        // Act
        final result = await userRepository.register(name, email, password);

        // Assert
        expect(result, isNull);
        verify(mockAuthService.register(name, email, password)).called(1);
      });
    });

    group('logout', () {
      test('should call auth service logout', () async {
        // Arrange
        when(mockAuthService.logout()).thenAnswer((_) async => {});

        // Act
        await userRepository.logout();

        // Assert
        verify(mockAuthService.logout()).called(1);
      });
    });

    group('isLoggedIn', () {
      test('should return true when user is logged in', () async {
        // Arrange
        when(mockAuthService.isLoggedIn()).thenAnswer((_) async => true);

        // Act
        final result = await userRepository.isLoggedIn();

        // Assert
        expect(result, isTrue);
        verify(mockAuthService.isLoggedIn()).called(1);
      });

      test('should return false when user is not logged in', () async {
        // Arrange
        when(mockAuthService.isLoggedIn()).thenAnswer((_) async => false);

        // Act
        final result = await userRepository.isLoggedIn();

        // Assert
        expect(result, isFalse);
        verify(mockAuthService.isLoggedIn()).called(1);
      });
    });

    group('getCurrentUser', () {
      test('should return current user when logged in', () async {
        // Arrange
        final expectedUser = User(
          id: '1',
          name: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockAuthService.getCurrentUser())
            .thenAnswer((_) async => expectedUser);

        // Act
        final result = await userRepository.getCurrentUser();

        // Assert
        expect(result, equals(expectedUser));
        verify(mockAuthService.getCurrentUser()).called(1);
      });

      test('should return null when not logged in', () async {
        // Arrange
        when(mockAuthService.getCurrentUser())
            .thenAnswer((_) async => null);

        // Act
        final result = await userRepository.getCurrentUser();

        // Assert
        expect(result, isNull);
        verify(mockAuthService.getCurrentUser()).called(1);
      });
    });
  });
}