import 'dart:async';

import '../../../../core/error/Failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/number_trivia_local_data_source.dart';
import '../datasources/number_trivia_remote_data_source.dart';
import '../../domain/contracts/repositories/number_trivia_repository.dart';
import '../../domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

typedef Future<NumberTrivia> _concreteOrRandomChooser();

class NumberTrivialRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemodeDataSource remodeDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NumberTrivialRepositoryImpl({
    @required this.remodeDataSource,
    @required this.localDataSource,
    @required this.networkInfo,
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
      int number) async {
    return await _getTrivia(
        () => remodeDataSource.getConcreteNumberTrivia(number));
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    return await _getTrivia(() => remodeDataSource.getRandomNumberTrivia());
  }

  Future<Either<Failure, NumberTrivia>> _getTrivia(
      _concreteOrRandomChooser getConreteOrRandom) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia = await getConreteOrRandom();
        localDataSource.cacheNumberTrivia(remoteTrivia);

        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localtTrivia = await localDataSource.getLastNumberTrivia();
        return Right(localtTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
