// core/Dependency_njection/service_locator.dart
import 'package:buldm/core/http/socket.io/socketserver.dart';
import 'package:buldm/features/Add_Post/presentation/bloc/location_cubit/location_cubit.dart';
import 'package:buldm/features/auth/data/datasource/localdatasource.dart';
import 'package:buldm/features/auth/data/datasource/remotedatasource.dart';
import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/data/repositery/AuthRepositoryImpl.dart';
import 'package:buldm/features/auth/domain/usecases/forgotPasswordusecase.dart';
import 'package:buldm/features/auth/domain/usecases/get_currentuser_usercase.dart';
import 'package:buldm/features/auth/domain/usecases/google_auth_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/resetpasswordusecase.dart';
import 'package:buldm/features/auth/domain/usecases/sendVerificationEmailAgain_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/signin_user_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/signout_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/signup_user_usecase.dart';
import 'package:buldm/features/auth/domain/usecases/verifyCodeusecase.dart';
import 'package:buldm/features/auth/domain/usecases/verifyEmailCode.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/chat/data/datasource/chat_remote_data_source.dart';
import 'package:buldm/features/chat/data/repo/chatrepoimp.dart';
import 'package:buldm/features/chat/domain/repo/chatrepo.dart';
import 'package:buldm/features/chat/domain/usecases/getAllMessagesById.dart';
import 'package:buldm/features/chat/domain/usecases/getMessagesByTId.dart';
import 'package:buldm/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:buldm/features/home/data/datasource/remote_post_data_source.dart';
import 'package:buldm/features/home/data/repository/postrepositoryimp.dart';
import 'package:buldm/features/home/domain/repository/postrepository.dart';
import 'package:buldm/features/home/domain/usecases/changeikepostUsecase.dart';
import 'package:buldm/features/home/domain/usecases/createPostUseCase.dart';
import 'package:buldm/features/home/domain/usecases/deletpostUsecase.dart';
import 'package:buldm/features/home/domain/usecases/getIndividualPostUseCase.dart';
import 'package:buldm/features/home/domain/usecases/getPostUseCase.dart';
import 'package:buldm/features/home/domain/usecases/getUserById.dart';
import 'package:buldm/features/home/domain/usecases/getcommentedpostUsecase.dart';
import 'package:buldm/features/home/domain/usecases/getlikedpostUsecase.dart';
import 'package:buldm/features/home/domain/usecases/setcommentUsecase.dart';
import 'package:buldm/features/home/domain/usecases/setreplycommentUsecase.dart';
import 'package:buldm/features/home/domain/usecases/updatepostUsecase.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/notifications/data/repositories/notification_repository.dart';
import 'package:buldm/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:buldm/features/profile/data/datasource/profile_remote_data_resource.dart';
import 'package:buldm/features/profile/data/repo/profilerepoimp.dart';
import 'package:buldm/features/profile/domain/repo/ProfileRepository.dart';
import 'package:buldm/features/profile/domain/usecases/fetchpost.dart';
import 'package:buldm/features/profile/domain/usecases/searchByname.dart';
import 'package:buldm/features/profile/domain/usecases/updateProfileAvatar_usecase.dart';
import 'package:buldm/features/profile/presentation/blocs/profile/profile_cubit.dart';
import 'package:buldm/features/profile/presentation/blocs/profilechanges/profilechanges_cubit.dart';
import 'package:buldm/features/search/presentation/bloc/ssearch/Search_Cubit.dart';
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
        // Only set Authorization if not already set on the request
        if (user != null && !options.headers.containsKey('Authorization')) {
          // Use the short-lived access token for normal requests
          options.headers['Authorization'] = 'Bearer ${user.token}';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Retry transient network/timeout errors with exponential backoff
        const maxRetries = 2;
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.connectionError) {
          final req = error.requestOptions;
          final attempt = (req.extra['retry_attempt'] as int?) ?? 0;
          if (attempt < maxRetries) {
            final delay = Duration(milliseconds: 500 * (1 << attempt));
            await Future.delayed(delay);
            req.extra['retry_attempt'] = attempt + 1;
            try {
              final retryResponse = await dio.fetch(req);
              return handler.resolve(retryResponse);
            } catch (_) {
              // fall through to existing error handling
            }
          }
        }
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
    // baseUrl: 'https://buldm.vercel.app/api/v1',
    //  for testing on real device
    baseUrl: 'http://192.168.1.12:3000/api/v1',
    headers: {
      'Content-Type': 'application/json',
    },
    // Increase timeouts to accommodate occasional cold starts/slow network
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 30),
  ));
  setupDio(dio);
  sl.registerLazySingleton<Dio>(() => dio);

  /// ✅ Auth Module
  sl.registerLazySingleton<ProfileRemoteDataResourceImpl>(
    () => ProfileRemoteDataResourceImpl(
        dio: sl(), authLocalDataSourceImpl: sl<AuthLocalDataSourceImpl>()),
  );
  // Data Sources
  sl.registerLazySingleton<ProfileRepository>(() => Profilerepoimp(
      profileRemoteDataResource: sl<ProfileRemoteDataResourceImpl>()));
  sl.registerLazySingleton<AuthRemoteDataSourceImpl>(
      () => AuthRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<AuthLocalDataSourceImpl>(
      () => AuthLocalDataSourceImpl(Hive.box<UserModel>('user')));
  // Repository
  sl.registerLazySingleton<AuthRepositoryImpl>(() => AuthRepositoryImpl(
        remoteDataSourceImpl: sl(),
        localDataSourceImpl: sl(),
      ));
  // Use Cases
  sl.registerLazySingleton(
      () => UpdateProfileAvatarUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(
      () => SignInUserUseCase(repository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(
      () => SignUpUserUseCase(repository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(
      () => GoogleAuthUsecase(authRepository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(
      () => GetCurrentuserUsercase(authRepository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(
      () => SignOutUseCase(authRepository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(
      () => VerifyEmailCode(authRepository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(() =>
      SendVerificationEmailAgainUseCase(repository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(
      () => ForgotPasswordUseCase(repository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(
      () => ResetPassword(repository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(
      () => VerifyCode(repository: sl<AuthRepositoryImpl>()));
  // Auth Cubit
  // ProfilechangesCubit
  sl.registerFactory(() => ProfilechangesCubit(
        updateProfileAvatarUsecase: sl(),
      ));
  final authCubit = AuthCubit(
    // updateProfileAvatarUsecase: sl(),
    forgotPasswordUseCase: sl(),
    passwordResetRequest: sl(),
    verificationCode: sl(),
    signInUserUseCase: sl(),
    sendVerificationEmailAgain: sl(),
    verifyEmailCode: sl(),
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
      () => RemotePostDataSourceImpl(dio: sl<Dio>()));

  // Repository
  sl.registerLazySingleton<Postrepository>(() =>
      Postrepositoryimp(remotePostDataSource: sl<RemotePostDataSource>()));

  // Use Cases

  sl.registerLazySingleton(
      () => GetPostUseCase(postrepository: sl<Postrepository>()));
  sl.registerLazySingleton<GetIndividualPostUseCase>(
      () => GetIndividualPostUseCase(postrepository: sl<Postrepository>()));
  sl.registerLazySingleton(() => Getuserbyid(postRepository: sl()));
  sl.registerLazySingleton<Postrepositoryimp>(
    () => Postrepositoryimp(remotePostDataSource: sl<RemotePostDataSource>()),
  );
  sl.registerLazySingleton(
      () => Getlikedpostusecase(postRepository: sl<Postrepository>()));
  sl.registerLazySingleton(
      () => GetCommentedPostUseCase(postRepository: sl<Postrepository>()));
  sl.registerLazySingleton(
      () => UpdatePostUseCase(postRepository: sl<Postrepository>()));
  sl.registerLazySingleton(
      () => SetReplyCommentUseCase(postRepository: sl<Postrepository>()));
  sl.registerLazySingleton(
      () => SetCommentUseCase(postRepository: sl<Postrepository>()));
  sl.registerLazySingleton(
      () => DeletePostUseCase(postRepository: sl<Postrepository>()));
  sl.registerLazySingleton(
      () => ChangeLikePostUseCase(postRepository: sl<Postrepository>()));
  sl.registerLazySingleton(
      () => Createpostusecase(postrepository: sl<Postrepository>()));

  // Blocs

  sl.registerFactory(() => PostBloc(
      getlikedpostusecase: sl<Getlikedpostusecase>(),
      getCurrentuserUsercase: sl<GetCurrentuserUsercase>(),
      getPostUseCase: sl<GetPostUseCase>(),
      getIndividualPostUseCase: sl<GetIndividualPostUseCase>(),
      createPostUsecase: sl<Createpostusecase>(),
      getCommentedPostUseCase: sl<GetCommentedPostUseCase>(),
      updatePostUseCase: sl<UpdatePostUseCase>(),
      setReplyCommentUseCase: sl<SetReplyCommentUseCase>(),
      setCommentUseCase: sl<SetCommentUseCase>(),
      deletePostUseCase: sl<DeletePostUseCase>(),
      changeLikePostUseCase: sl<ChangeLikePostUseCase>()));
  sl.registerFactory(() => UserBloc(getuserbyid: sl()));
  // location cubit
  sl.registerFactory(() => LocationCubit());

  // Profile Repository (reusing existing RemotePostDataSource)

  // fetch post UseCase
  sl.registerLazySingleton(
      () => Fetchpost(profileRepository: sl<ProfileRepository>()));

  // Profile cubit
  sl.registerFactory(() => ProfileCubit(
        fetchpostUseCase: sl<Fetchpost>(),
      ));

  sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(dio: sl<Dio>()));
  sl.registerLazySingleton<ChatRepo>(
      () => ChatRepoImpl(sl<ChatRemoteDataSource>()));
  sl.registerLazySingleton(() => GetMessagesByTId(sl<ChatRepo>()));
  sl.registerLazySingleton(() => GetAllMessagesById(sl<ChatRepo>()));
  sl.registerLazySingleton(() => SocketService());

  // Chat Bloc
  sl.registerFactory(() => ChatBloc(
        getAllMessagesById: sl<GetAllMessagesById>(),
        getMessagesByTId: sl<GetMessagesByTId>(),
        socketService: sl<SocketService>(),
      ));

  //search cubit
  sl.registerLazySingleton(
      () => SearchByName(profileRepository: sl<ProfileRepository>()));
  sl.registerLazySingleton(() => SearchCubit(searchByName: sl<SearchByName>()));

  // Notification Repository
  sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepository());

  // Notification Bloc
  sl.registerFactory(() => NotificationBloc(sl<NotificationRepository>()));
}
