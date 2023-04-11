import 'dart:async';

import '../../../../core/error/Failures.dart';
import '../../../../core/usecases/usecases.dart';
import '../contracts/repositories/number_trivia_repository.dart';
import '../entities/number_trivia.dart';
import 'package:dartz/dartz.dart';


class GetRandomNumberTrivia implements Usecase<NumberTrivia, NoParams> {
  final NumberTriviaRepository repository;

  GetRandomNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(NoParams params) async {
    return await repository.getRandomNumberTrivia();
  }
}


