import 'package:buldm/features/auth/data/datasource/localdatasource.dart';
import 'package:buldm/features/auth/data/datasource/remotedatasource.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/data/repositery/AuthRepositoryImpl.dart';
import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ✅ Dio instance
  sl.registerLazySingleton<Dio>(() => Dio(
        BaseOptions(
          baseUrl: 'http://10.0.2.2:3000/api/v1',
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      ));

  // ✅ Remote Data Source
  sl.registerLazySingleton<AuthRemoteDataSourceImpl>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // ✅ Local Data Source

  sl.registerLazySingleton<AuthLocalDataSourceImpl>(
    () => AuthLocalDataSourceImpl(Hive.box<UserModel>('user')),
  );

  // ✅ Repository
  sl.registerLazySingleton<authRepositoryInterface>(
    () => AuthRepositoryImpl(
      remoteDataSourceImpl: sl(),
      localDataSourceImpl: sl(),
    ),
  );

  // ✅ AuthCubit - Singleton (created on app start)
  final authCubit = AuthCubit(authRepository: sl());
  sl.registerSingleton<AuthCubit>(authCubit);

// ✅ Call appStarted() immediately
  authCubit.appStarted();
}
