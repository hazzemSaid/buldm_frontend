import 'package:buldm/features/Add_Post/presentation/bloc/location_cubit/location_cubit.dart';
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
import 'package:buldm/features/home/domain/usecases/createPostUseCase.dart';
import 'package:buldm/features/home/domain/usecases/getPostUseCase.dart';
import 'package:buldm/features/home/domain/usecases/getUserById.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/profile/data/datasource/profile_remote_data_resource.dart';
import 'package:buldm/features/profile/data/repo/profilerepoimp.dart';
import 'package:buldm/features/profile/domain/repo/ProfileRepository.dart';
import 'package:buldm/features/profile/domain/usecases/fetchpost.dart';
import 'package:buldm/features/profile/presentation/blocs/profile/profile_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final sl = GetIt.instance;

/// 🔐 Dio Interceptor setup
void setupDio(Dio dio) {
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final userBox = Hive.box<UserModel>('user');
        final user = userBox.get('user');
        if (user != null) {
          options.headers['Authorization'] = 'Bearer ${user.refreshToken}';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 &&
            !error.requestOptions.path.contains('/refreshToken')) {
          final userBox = Hive.box<UserModel>('user');
          final user = userBox.get('user');

          if (user == null) {
            await userBox.clear();
            return handler.reject(error);
          }

          try {
            final response = await dio.post('/user/refreshToken', data: {
              'refreshToken': user.refreshToken,
            });

            if (response.statusCode == 200 &&
                response.data['success'] == true) {
              final updatedUser = UserModel.fromJson(response.data['user']);
              await userBox.put('user', updatedUser);

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
    ),
  );
}

/// 🧠 App Dependency Injection Setup
Future<void> init() async {
  /// ✅ Dio
  final dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.8:3000/api/v1',
    //  for testing on real device
    // baseUrl: 'http://10.0.2.2:3000/api/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
    },
  ));
  setupDio(dio);
  sl.registerLazySingleton<Dio>(() => dio);

  /// ✅ Auth Module

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSourceImpl>(
      () => AuthRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<AuthLocalDataSourceImpl>(
      () => AuthLocalDataSourceImpl(Hive.box<UserModel>('user')));

  // Repository
  sl.registerLazySingleton<authRepositoryInterface>(() => AuthRepositoryImpl(
      remoteDataSourceImpl: sl(), localDataSourceImpl: sl()));

  // Use Cases
  sl.registerLazySingleton(() => SignInUserUseCase(repository: sl()));
  sl.registerLazySingleton(() => SignUpUserUseCase(repository: sl()));
  sl.registerLazySingleton(() => GoogleAuthUsecase(authRepository: sl()));
  sl.registerLazySingleton(() => GetCurrentuserUsercase(authRepository: sl()));
  sl.registerLazySingleton(() => SignOutUseCase(authRepository: sl()));

  // Auth Cubit
  final authCubit = AuthCubit(
    signInUserUseCase: sl(),
    signUpUserUseCase: sl(),
    googleAuthUsecase: sl(),
    getCurrentuserUsercase: sl(),
    signOutUseCase: sl(),
  );
  sl.registerSingleton<AuthCubit>(authCubit);
  authCubit.appStarted(); // Optional: check login on app start

  /// ✅ Home Module - Post

  // Data Source
  sl.registerLazySingleton<RemotePostDataSource>(
      () => RemotePostDataSourceImpl(dio: sl()));

  // Repository
  sl.registerLazySingleton<Postrepository>(
      () => Postrepositoryimp(remotePostDataSource: sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetPostUseCase(postrepository: sl()));
  sl.registerLazySingleton(() => Getuserbyid(postRepository: sl()));
  sl.registerLazySingleton<Postrepositoryimp>(
    () => Postrepositoryimp(remotePostDataSource: sl()),
  );
//createPostUsecase
  sl.registerLazySingleton(() => Createpostusecase(postrepository: sl()));

  // Blocs

  sl.registerFactory(() => PostBloc(
      getCurrentuserUsercase: sl(),
      getPostUseCase: sl(),
      createPostUsecase: sl()));
  sl.registerFactory(() => UserBloc(getuserbyid: sl()));
  // location cubit
  sl.registerFactory(() => LocationCubit());
  sl.registerLazySingleton<ProfileRemoteDataResource>(
    () => ProfileRemoteDataResourceImpl(dio: sl()),
  );

  // Profile Repository (reusing existing RemotePostDataSource)
  sl.registerLazySingleton<ProfileRepository>(() => Profilerepoimp(
      profileRemoteDataResource: sl<ProfileRemoteDataResource>()));

  // fetch post UseCase
  sl.registerLazySingleton(
      () => Fetchpost(profileRepository: sl<ProfileRepository>()));
  // Profile cubit
  sl.registerFactory(() => ProfileCubit(
        fetchpostUseCase: sl<Fetchpost>(),
      ));
}
