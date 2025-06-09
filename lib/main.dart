import 'package:buldm/features/auth/data/model/usermodel.dart';
import 'package:buldm/features/auth/data/repositery/AuthRepositoryImpl%20.dart';
import 'package:buldm/features/auth/presentaion/view/viewmodel/auth/auth_cubit.dart';
import 'package:buldm/firebase_options.dart';
import 'package:buldm/l10n/app_localizations.dart';
import 'package:buldm/provider/localization/localization_cubit.dart';
import 'package:buldm/routes/routes.dart';
import 'package:buldm/utils/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //hive for usermodel
  Hive.init((await getApplicationDocumentsDirectory()).path);
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>('user');
  // Initialize FlutterLocalization
  await FlutterLocalization.instance.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Enable verbose logging for debugging (remove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // Initialize with your OneSignal App ID
  OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID']!);
  // Use this method to prompt for push notifications.
  OneSignal.Notifications.requestPermission(true);
  FlutterLocalization.instance.init(
    mapLocales: [
      const MapLocale('en', {'en': 'US'}),
      const MapLocale('ar', {'ar': 'EG'}),
    ],
    initLanguageCode: 'en',
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocalizationCubit()),
        BlocProvider(create: (_) => AuthCubit(Authrepositoryimpl())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationCubit, Locale>(
      builder: (context, locale) {
        return MaterialApp.router(
          locale: locale,
          supportedLocales: const [Locale('en', 'US'), Locale('ar', 'EG')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return supportedLocales.first;
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          darkTheme: AppTheme.darkTheme,
          routerConfig: router,
          title: 'Buldm App',
          theme: AppTheme.darkTheme,
        );
      },
    );
  }
}
