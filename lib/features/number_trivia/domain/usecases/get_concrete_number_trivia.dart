import 'dart:async';

import '../../../../core/error/Failures.dart';
import '../../../../core/usecases/usecases.dart';
import '../contracts/repositories/number_trivia_repository.dart';
import '../entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class GetConcreteNumberTrivia implements Usecase<NumberTrivia, Params> {
  final NumberTriviaRepository repository;

  GetConcreteNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(Params params) async {
    return repository.getConcreteNumberTrivia(params.number);
  }
}


class Params extends Equatable{
  final int number;
  Params({
    @required this.number
  }): super([number]);
}