import 'package:buldm/features/auth/data/datasource/localdatasource.dart';
import 'package:buldm/features/auth/data/datasource/remotedatasource.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/data/repositery/AuthRepositoryImpl.dart';
import 'package:buldm/features/auth/domain/repository/Iauthrepository.dart';
import 'package:buldm/features/auth/domain/usecases/get_currentuser_usercase.dart';
import 'package:buldm/features/auth/domain/usecases/google_auth_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/signin_user_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/signout_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/signup_user_usecase.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/home/data/datasource/remote_post_data_source.dart';
import 'package:buldm/features/home/data/repository/postrepositoryimp.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';
import 'package:buldm/features/home/domain/usecases/getPostUseCase.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final sl = GetIt.instance;
// final storage = FlutterSecureStorage(); // Secure token storage

// ✅ Interceptor setup with token refresh logic
void setupDio(Dio dio) {
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final userBox = Hive.box<UserModel>('user');
      final user = userBox.get('user');
      if (user != null && user.token != null) {
        options.headers['Authorization'] = 'Bearer ${user.token}';
      }
      return handler.next(options);
    },
    onError: (DioException error, handler) async {
      if (error.response?.statusCode == 401 &&
          !error.requestOptions.path.contains('/refreshToken')) {
        final userBox = Hive.box<UserModel>('user');
        final user = userBox.get('user');

        if (user == null || user.refreshToken == null) {
          await userBox.clear();
          return handler.reject(error);
        }

        try {
          // 🔁 Call the correct refresh token endpoint
          final response = await dio.post('/user/refreshToken', data: {
            'refreshToken': user.refreshToken,
          });

          if (response.statusCode == 200 && response.data['success'] == true) {
            final userJson = response.data['user'];

            // Make sure this uses fromJson correctly
            final updatedUser = UserModel.fromJson(userJson);

            // Save new user with fresh tokens
            await userBox.put('user', updatedUser);

            // Retry original request with new token
            final originalRequest = error.requestOptions;
            originalRequest.headers['Authorization'] =
                'Bearer ${updatedUser.token}';

            final retryResponse = await dio.fetch(originalRequest);
            return handler.resolve(retryResponse);
          } else {
            await userBox.clear();
            return handler.reject(error);
          }
        } catch (_) {
          await userBox.clear();
          return handler.reject(error);
        }
      }

      return handler.next(error);
    },
  ));
}

Future<void> init() async {
  // ✅ Dio instance

  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:3000/api/v1',
    ),
  );
  setupDio(dio); // مهم: إعداد interceptor قبل ما تسجّله في GetIt
  sl.registerLazySingleton<Dio>(() => dio);
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

  // ✅ Use Cases
  sl.registerLazySingleton(() => SignInUserUseCase(repository: sl()));
  sl.registerLazySingleton(() => SignUpUserUseCase(repository: sl()));
  sl.registerLazySingleton(() => GoogleAuthUsecase(authRepository: sl()));
  sl.registerLazySingleton(() => GetCurrentuserUsercase(authRepository: sl()));
  sl.registerLazySingleton(() => SignOutUseCase(authRepository: sl()));

  // ✅ AuthCubit
  final authCubit = AuthCubit(
    signInUserUseCase: sl(),
    signUpUserUseCase: sl(),
    googleAuthUsecase: sl(),
    getCurrentuserUsercase: sl(),
    signOutUseCase: sl(),
  );
  sl.registerSingleton<AuthCubit>(authCubit);

  // ✅ Auto-run auth check
  authCubit.appStarted();

  // ✅ Post Use Case
  sl.registerLazySingleton(() => GetPostUseCase(postrepository: sl()));

  // ✅ Post Repository
  sl.registerLazySingleton<Postrepository>(() => Postrepositoryimp(
        remotePostDataSource: RemotePostDataSourceImpl(dio: sl()),
      ));

  // ✅ Remote Post Data Source
  sl.registerLazySingleton<RemotePostDataSource>(
    () => RemotePostDataSourceImpl(dio: sl()),
  );

  // ✅ Post Bloc

  sl.registerFactory<PostBloc>(
    () => PostBloc(
      getCurrentuserUsercase: sl(),
      getPostUseCase: sl(),
    ),
  );
  // add the event to load posts
}
