import 'package:clean_architecture_course/core/usecases/usecases.dart';
import 'package:clean_architecture_course/features/number_trivia/domain/contracts/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  GetRandomNumberTrivia usecase;
  MockNumberTriviaRepository mockNumberTriviaRepository = MockNumberTriviaRepository();

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(mockNumberTriviaRepository);
  });

  final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');
  test(
    'should get trivia random number from the repository', 
    () async {
    // arrange
    when(mockNumberTriviaRepository.getRandomNumberTrivia())
        .thenAnswer((_) async => Right(tNumberTrivia));

    final result = await usecase(NoParams());

    expect(result, Right(tNumberTrivia));
    verify(mockNumberTriviaRepository.getRandomNumberTrivia());
    verifyNoMoreInteractions(mockNumberTriviaRepository);
  });
}
