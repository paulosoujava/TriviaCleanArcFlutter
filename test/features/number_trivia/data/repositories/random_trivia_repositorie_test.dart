import 'package:clean_architecture_course/core/error/Failures.dart';
import 'package:clean_architecture_course/core/error/exceptions.dart';
import 'package:clean_architecture_course/core/network/network_info.dart';
import 'package:clean_architecture_course/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_course/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_course/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_architecture_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemodeDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTrivialRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;
  NumberTriviaModel tNumberTrivaModel;
  NumberTrivia tNumberTrivia;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockLocalDataSource = MockLocalDataSource();
    repository = NumberTrivialRepositoryImpl(
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
      remodeDataSource: mockRemoteDataSource,
    );
    tNumberTrivaModel = NumberTriviaModel(number: 123, text: 'test trivia');
    tNumberTrivia = tNumberTrivaModel;
  });

  void runTestsInternetInModeConnected(bool isOnLine, Function body) {
    final isOn = isOnLine ? 'is on' : 'is off';
    group('device is $isOn', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => isOnLine);
      });
      body();
    });
  }

  runTestsInternetInModeConnected(true, () {
    test('should check if the device is online', () async {
      //arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      //act
      repository.getRandomNumberTrivia();
      //assert
      verify(mockNetworkInfo.isConnected);
    });
    test(
        'should return remote data when the call to remote data source is successful',
        () async {
      when(mockRemoteDataSource.getRandomNumberTrivia())
          .thenAnswer((_) async => tNumberTrivaModel);
      final result = await repository.getRandomNumberTrivia();
      verify(mockRemoteDataSource.getRandomNumberTrivia());
      expect(result, Right(tNumberTrivia));
    });

    test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
      when(mockRemoteDataSource.getRandomNumberTrivia())
          .thenAnswer((_) async => tNumberTrivaModel);

      await repository.getRandomNumberTrivia();

      verify(mockRemoteDataSource.getRandomNumberTrivia());
      verify(mockLocalDataSource.cacheNumberTrivia(tNumberTrivaModel));
    });

    test(
        'should return srver failure when the call to remote data source is unsuccessful',
        () async {
      when(mockRemoteDataSource.getRandomNumberTrivia())
          .thenThrow(ServerException());

      final result = await repository.getRandomNumberTrivia();

      verify(mockRemoteDataSource.getRandomNumberTrivia());
      verifyZeroInteractions(mockLocalDataSource);
      expect(result, Left(ServerFailure()));
    });
  });

  runTestsInternetInModeConnected(false, () {
    setUp(() {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
    });
    test(
        'should return last locally cached data when the cached data is present',
        () async {
      when(mockLocalDataSource.getLastNumberTrivia())
          .thenAnswer((_) async => tNumberTrivaModel);

      final result = await repository.getRandomNumberTrivia();

      verifyZeroInteractions(mockRemoteDataSource);
      verify(mockLocalDataSource.getLastNumberTrivia());
      expect(result, Right(tNumberTrivia));
    });

    test('should return CacheFailure when there is no cached data present',
        () async {
      when(mockLocalDataSource.getLastNumberTrivia())
          .thenThrow(CacheException());

      final result = await repository.getRandomNumberTrivia();

      verifyZeroInteractions(mockRemoteDataSource);
      verify(mockLocalDataSource.getLastNumberTrivia());
      expect(result, Left(CacheFailure()));
    });
  });
}
