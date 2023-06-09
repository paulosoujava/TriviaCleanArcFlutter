import 'dart:async';

import 'package:clean_architecture_course/core/network/network_info.dart';
import 'package:clean_architecture_course/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_course/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_course/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'core/util/input_converter.dart';
import 'features/number_trivia/domain/contracts/repositories/number_trivia_repository.dart';
import 'features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ! Features - Number Trivia
  sl.registerFactory(
    () => NumberTriviaBloc(
      concrete: sl(),
      random: sl(),
      inputConverter: sl(),
    ),
  );

  // ? Use cases
  sl.registerLazySingleton(() => GetConcreteNumberTrivia(sl()));
  sl.registerLazySingleton(() => GetRandomNumberTrivia(sl()));

  // ? Repository
  sl.registerLazySingleton<NumberTriviaRepository>(
    () => NumberTrivialRepositoryImpl(
      remodeDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ? Data sources
  sl.registerLazySingleton<NumberTriviaRemodeDataSource>(
    () => NumberTriviaRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<NumberTriviaLocalDataSource>(
    () => NumberTriviaLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // * External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => DataConnectionChecker());
}
