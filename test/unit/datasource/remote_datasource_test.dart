import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_mvvm/core/datasource/remote_datasource.dart';
import 'package:flutter_mvvm/core/exceptions/exceptions.dart';

// 生成Mock类
@GenerateMocks([Dio])
import 'remote_datasource_test.mocks.dart';

void main() {
  group('RemoteDataSource Tests', () {
    late RemoteDataSourceImpl dataSource;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      dataSource = RemoteDataSourceImpl(mockDio);
    });

    group('get', () {
      test('should return data when request is successful', () async {
        // Arrange
        const endpoint = '/users/1';
        final responseData = {'id': '1', 'name': 'Test User'};
        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: endpoint),
        );

        when(mockDio.get(endpoint, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => response);

        // Act
        final result = await dataSource.get(endpoint);

        // Assert
        expect(result, equals(responseData));
        verify(mockDio.get(endpoint, queryParameters: anyNamed('queryParameters'))).called(1);
      });

      test('should throw NetworkException when request fails with 404', () async {
        // Arrange
        const endpoint = '/users/999';
        final dioError = DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: endpoint),
          ),
          type: DioExceptionType.badResponse,
        );

        when(mockDio.get(endpoint, queryParameters: anyNamed('queryParameters')))
            .thenThrow(dioError);

        // Act & Assert
        expect(
          () => dataSource.get(endpoint),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should throw NetworkException when connection timeout occurs', () async {
        // Arrange
        const endpoint = '/users/1';
        final dioError = DioException(
          requestOptions: RequestOptions(path: endpoint),
          type: DioExceptionType.connectionTimeout,
        );

        when(mockDio.get(endpoint, queryParameters: anyNamed('queryParameters')))
            .thenThrow(dioError);

        // Act & Assert
        expect(
          () => dataSource.get(endpoint),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getAll', () {
      test('should return list of data when request is successful', () async {
        // Arrange
        const endpoint = '/users';
        final responseData = [
          {'id': '1', 'name': 'User 1'},
          {'id': '2', 'name': 'User 2'},
        ];
        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: endpoint),
        );

        when(mockDio.get(endpoint, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => response);

        // Act
        final result = await dataSource.getAll(endpoint);

        // Assert
        expect(result, equals(responseData));
        verify(mockDio.get(endpoint, queryParameters: anyNamed('queryParameters'))).called(1);
      });

      test('should return empty list when response data is null', () async {
        // Arrange
        const endpoint = '/users';
        final response = Response(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: endpoint),
        );

        when(mockDio.get(endpoint, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => response);

        // Act
        final result = await dataSource.getAll(endpoint);

        // Assert
        expect(result, equals([]));
      });
    });

    group('create', () {
      test('should return created data when request is successful', () async {
        // Arrange
        const endpoint = '/users';
        final requestData = {'name': 'New User', 'email': 'new@example.com'};
        final responseData = {'id': '3', 'name': 'New User', 'email': 'new@example.com'};
        final response = Response(
          data: responseData,
          statusCode: 201,
          requestOptions: RequestOptions(path: endpoint),
        );

        when(mockDio.post(endpoint, data: requestData))
            .thenAnswer((_) async => response);

        // Act
        final result = await dataSource.create(endpoint, requestData);

        // Assert
        expect(result, equals(responseData));
        verify(mockDio.post(endpoint, data: requestData)).called(1);
      });

      test('should throw NetworkException when creation fails', () async {
        // Arrange
        const endpoint = '/users';
        final requestData = {'name': 'New User'};
        final dioError = DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(path: endpoint),
          ),
          type: DioExceptionType.badResponse,
        );

        when(mockDio.post(endpoint, data: requestData))
            .thenThrow(dioError);

        // Act & Assert
        expect(
          () => dataSource.create(endpoint, requestData),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('update', () {
      test('should return updated data when request is successful', () async {
        // Arrange
        const endpoint = '/users/1';
        final requestData = {'name': 'Updated User'};
        final responseData = {'id': '1', 'name': 'Updated User'};
        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: endpoint),
        );

        when(mockDio.put(endpoint, data: requestData))
            .thenAnswer((_) async => response);

        // Act
        final result = await dataSource.update(endpoint, requestData);

        // Assert
        expect(result, equals(responseData));
        verify(mockDio.put(endpoint, data: requestData)).called(1);
      });
    });

    group('delete', () {
      test('should complete successfully when delete request succeeds', () async {
        // Arrange
        const endpoint = '/users/1';
        final response = Response(
          statusCode: 204,
          requestOptions: RequestOptions(path: endpoint),
        );

        when(mockDio.delete(endpoint))
            .thenAnswer((_) async => response);

        // Act & Assert
        expect(() => dataSource.delete(endpoint), returnsNormally);
        await dataSource.delete(endpoint);
        verify(mockDio.delete(endpoint)).called(1);
      });

      test('should throw NetworkException when delete fails', () async {
        // Arrange
        const endpoint = '/users/1';
        final dioError = DioException(
          requestOptions: RequestOptions(path: endpoint),
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: endpoint),
          ),
          type: DioExceptionType.badResponse,
        );

        when(mockDio.delete(endpoint))
            .thenThrow(dioError);

        // Act & Assert
        expect(
          () => dataSource.delete(endpoint),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('count', () {
      test('should return count when request is successful', () async {
        // Arrange
        const endpoint = '/users/count';
        final responseData = {'count': 42};
        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: endpoint),
        );

        when(mockDio.get(endpoint, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => response);

        // Act
        final result = await dataSource.count(endpoint);

        // Assert
        expect(result, equals(42));
        verify(mockDio.get(endpoint, queryParameters: anyNamed('queryParameters'))).called(1);
      });

      test('should return 0 when count is not found in response', () async {
        // Arrange
        const endpoint = '/users/count';
        final responseData = {'total': 42}; // 不同的字段名
        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: endpoint),
        );

        when(mockDio.get(endpoint, queryParameters: anyNamed('queryParameters')))
            .thenAnswer((_) async => response);

        // Act
        final result = await dataSource.count(endpoint);

        // Assert
        expect(result, equals(0));
      });
    });
  });
}