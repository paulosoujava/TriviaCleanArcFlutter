part of 'number_trivia_bloc.dart';

@immutable
abstract class NumberTriviaEvent extends Equatable {
   NumberTriviaEvent([List props = const []]) : super(props);

}

class GetTriviaForConcreteNumber extends NumberTriviaEvent {
  final String numberString;
  

  GetTriviaForConcreteNumber(this.numberString);
}

class GetTriviaForRandomNumber extends NumberTriviaEvent {}
