import 'dart:async';

import '../../../../../core/error/Failures.dart';
import '../../entities/number_trivia.dart';
import 'package:dartz/dartz.dart';


abstract class NumberTriviaRepository {
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number);
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia();
}
