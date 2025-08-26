import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_mvvm/core/datasource/local_datasource.dart';
import 'package:flutter_mvvm/core/storage/storage_manager.dart';
import 'package:flutter_mvvm/core/exceptions/exceptions.dart';

// 生成Mock类
@GenerateMocks([IStorageManager])
import 'local_datasource_test.mocks.dart';

void main() {
  group('LocalDataSource Tests', () {
    late LocalDataSourceImpl dataSource;
    late MockIStorageManager mockStorageManager;

    setUp(() {
      mockStorageManager = MockIStorageManager();
      dataSource = LocalDataSourceImpl(mockStorageManager);
    });

    group('get', () {
      test('should return data when key exists and not expired', () async {
        // Arrange
        const key = 'user_1';
        final expectedData = {'id': '1', 'name': 'Test User'};
        final lastUpdated = DateTime.now().subtract(const Duration(minutes: 5));

        when(mockStorageManager.exists(key))
            .thenAnswer((_) async => true);
        when(mockStorageManager.get(key))
            .thenAnswer((_) async => expectedData);
        when(mockStorageManager.get('${key}_lastUpdated'))
            .thenAnswer((_) async => lastUpdated.millisecondsSinceEpoch);

        // Act
        final result = await dataSource.get(key);

        // Assert
        expect(result, equals(expectedData));
        verify(mockStorageManager.exists(key)).called(1);
        verify(mockStorageManager.get(key)).called(1);
      });

      test('should return null when key does not exist', () async {
        // Arrange
        const key = 'nonexistent_key';

        when(mockStorageManager.exists(key))
            .thenAnswer((_) async => false);

        // Act
        final result = await dataSource.get(key);

        // Assert
        expect(result, isNull);
        verify(mockStorageManager.exists(key)).called(1);
        verifyNever(mockStorageManager.get(key));
      });

      test('should return null when data is expired', () async {
        // Arrange
        const key = 'expired_key';
        final expiredTime = DateTime.now().subtract(const Duration(hours: 2));

        when(mockStorageManager.exists(key))
            .thenAnswer((_) async => true);
        when(mockStorageManager.get('${key}_lastUpdated'))
            .thenAnswer((_) async => expiredTime.millisecondsSinceEpoch);

        // Act
        final result = await dataSource.get(key, cacheDuration: const Duration(hours: 1));

        // Assert
        expect(result, isNull);
        verify(mockStorageManager.exists(key)).called(1);
        verifyNever(mockStorageManager.get(key));
      });

      test('should throw CacheException when storage operation fails', () async {
        // Arrange
        const key = 'error_key';

        when(mockStorageManager.exists(key))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => dataSource.get(key),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('getAll', () {
      test('should return all data with matching prefix', () async {
        // Arrange
        const prefix = 'users';
        final allKeys = ['users_1', 'users_2', 'products_1'];
        final userData1 = {'id': '1', 'name': 'User 1'};
        final userData2 = {'id': '2', 'name': 'User 2'};

        when(mockStorageManager.getAllKeys())
            .thenAnswer((_) async => allKeys);
        when(mockStorageManager.get('users_1'))
            .thenAnswer((_) async => userData1);
        when(mockStorageManager.get('users_2'))
            .thenAnswer((_) async => userData2);

        // Act
        final result = await dataSource.getAll(prefix);

        // Assert
        expect(result, hasLength(2));
        expect(result, contains(userData1));
        expect(result, contains(userData2));
        verify(mockStorageManager.getAllKeys()).called(1);
      });

      test('should return empty list when no matching keys found', () async {
        // Arrange
        const prefix = 'nonexistent';
        final allKeys = ['users_1', 'products_1'];

        when(mockStorageManager.getAllKeys())
            .thenAnswer((_) async => allKeys);

        // Act
        final result = await dataSource.getAll(prefix);

        // Assert
        expect(result, isEmpty);
        verify(mockStorageManager.getAllKeys()).called(1);
      });
    });

    group('save', () {
      test('should save data with timestamp', () async {
        // Arrange
        const key = 'user_1';
        final data = {'id': '1', 'name': 'Test User'};

        when(mockStorageManager.set(any, any))
            .thenAnswer((_) async => {});

        // Act
        await dataSource.save(key, data);

        // Assert
        verify(mockStorageManager.set(key, data)).called(1);
        verify(mockStorageManager.set(
          '${key}_lastUpdated',
          any,
        )).called(1);
      });

      test('should throw CacheException when save fails', () async {
        // Arrange
        const key = 'error_key';
        final data = {'id': '1', 'name': 'Test User'};

        when(mockStorageManager.set(key, data))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => dataSource.save(key, data),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('saveAll', () {
      test('should save all data items', () async {
        // Arrange
        const prefix = 'users';
        final dataList = [
          {'id': '1', 'name': 'User 1'},
          {'id': '2', 'name': 'User 2'},
        ];

        when(mockStorageManager.set(any, any))
            .thenAnswer((_) async => {});

        // Act
        await dataSource.saveAll(prefix, dataList);

        // Assert
        verify(mockStorageManager.set('${prefix}_0', dataList[0])).called(1);
        verify(mockStorageManager.set('${prefix}_1', dataList[1])).called(1);
        verify(mockStorageManager.set(
          '${prefix}_0_lastUpdated',
          any,
        )).called(1);
        verify(mockStorageManager.set(
          '${prefix}_1_lastUpdated',
          any,
        )).called(1);
      });
    });

    group('delete', () {
      test('should delete data and metadata', () async {
        // Arrange
        const key = 'user_1';

        when(mockStorageManager.remove(any))
            .thenAnswer((_) async => {});

        // Act
        await dataSource.delete(key);

        // Assert
        verify(mockStorageManager.remove(key)).called(1);
        verify(mockStorageManager.remove('${key}_lastUpdated')).called(1);
      });

      test('should throw CacheException when delete fails', () async {
        // Arrange
        const key = 'error_key';

        when(mockStorageManager.remove(key))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => dataSource.delete(key),
          throwsA(isA<CacheException>()),
        );
      });
    });

    group('exists', () {
      test('should return true when key exists', () async {
        // Arrange
        const key = 'user_1';

        when(mockStorageManager.exists(key))
            .thenAnswer((_) async => true);

        // Act
        final result = await dataSource.exists(key);

        // Assert
        expect(result, isTrue);
        verify(mockStorageManager.exists(key)).called(1);
      });

      test('should return false when key does not exist', () async {
        // Arrange
        const key = 'nonexistent_key';

        when(mockStorageManager.exists(key))
            .thenAnswer((_) async => false);

        // Act
        final result = await dataSource.exists(key);

        // Assert
        expect(result, isFalse);
        verify(mockStorageManager.exists(key)).called(1);
      });
    });

    group('clear', () {
      test('should clear all data with matching prefix', () async {
        // Arrange
        const prefix = 'users';
        final allKeys = ['users_1', 'users_1_lastUpdated', 'users_2', 'products_1'];

        when(mockStorageManager.getAllKeys())
            .thenAnswer((_) async => allKeys);
        when(mockStorageManager.remove(any))
            .thenAnswer((_) async => {});

        // Act
        await dataSource.clear(prefix);

        // Assert
        verify(mockStorageManager.remove('users_1')).called(1);
        verify(mockStorageManager.remove('users_1_lastUpdated')).called(1);
        verify(mockStorageManager.remove('users_2')).called(1);
        verifyNever(mockStorageManager.remove('products_1'));
      });
    });

    group('isExpired', () {
      test('should return true when data is expired', () async {
        // Arrange
        const key = 'user_1';
        final expiredTime = DateTime.now().subtract(const Duration(hours: 2));

        when(mockStorageManager.get('${key}_lastUpdated'))
            .thenAnswer((_) async => expiredTime.millisecondsSinceEpoch);

        // Act
        final result = await dataSource.isExpired(key, const Duration(hours: 1));

        // Assert
        expect(result, isTrue);
      });

      test('should return false when data is not expired', () async {
        // Arrange
        const key = 'user_1';
        final recentTime = DateTime.now().subtract(const Duration(minutes: 30));

        when(mockStorageManager.get('${key}_lastUpdated'))
            .thenAnswer((_) async => recentTime.millisecondsSinceEpoch);

        // Act
        final result = await dataSource.isExpired(key, const Duration(hours: 1));

        // Assert
        expect(result, isFalse);
      });

      test('should return true when no timestamp found', () async {
        // Arrange
        const key = 'user_1';

        when(mockStorageManager.get('${key}_lastUpdated'))
            .thenAnswer((_) async => null);

        // Act
        final result = await dataSource.isExpired(key, const Duration(hours: 1));

        // Assert
        expect(result, isTrue);
      });
    });
  });
}