import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_standard/config/config.dart';
import 'package:mobile_app_standard/feature/auth/bloc/auth_bloc.dart';
import 'package:mobile_app_standard/feature/auth/pages/user_type_selection_page.dart';
import 'package:mobile_app_standard/feature/home/bloc/websocket/websocket_bloc.dart';
import 'package:mobile_app_standard/feature/nurse/bloc/village_analytics_bloc.dart';
import 'package:mobile_app_standard/feature/nurse/bloc/village_bloc.dart';
import 'package:mobile_app_standard/feature/patient/bloc/patient_bloc.dart';
import 'package:mobile_app_standard/feature/screening/bloc/screening_bloc.dart';
import 'package:mobile_app_standard/feature/todo/bloc/todo_bloc.dart';
import 'package:mobile_app_standard/feature/vhv/bloc/vhv_bloc.dart';
import 'package:mobile_app_standard/i18n/i18n.dart';
import 'package:mobile_app_standard/locator.dart';
import 'package:mobile_app_standard/shared/bloc/language/language_bloc.dart';
import 'package:mobile_app_standard/shared/bloc/language/language_state.dart';
import 'package:mobile_app_standard/shared/tokens/p_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadEnv();
  await initLocator();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => locator<AuthBloc>()),
        BlocProvider<PatientBloc>(create: (context) => locator<PatientBloc>()),
        BlocProvider<ScreeningBloc>(create: (context) => locator<ScreeningBloc>()),
        BlocProvider<VhvBloc>(create: (context) => locator<VhvBloc>()),
        BlocProvider<VillageBloc>(create: (context) => locator<VillageBloc>()),
        BlocProvider<VillageAnalyticsBloc>(create: (context) => locator<VillageAnalyticsBloc>()),
        BlocProvider<TodoBloc>(create: (context) => locator<TodoBloc>()),
        BlocProvider<WebsocketBloc>(create: (context) => locator<WebsocketBloc>()),
        BlocProvider<LanguageBloc>(create: (context) => locator<LanguageBloc>()),
      ],
      child: const NcdScreeningApp(),
    ),
  );
}

class NcdScreeningApp extends StatelessWidget {
  const NcdScreeningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        return MaterialApp(
          title: 'NCD Screening Mobile',
          debugShowCheckedModeBanner: false,
          supportedLocales: I18n.all,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: languageState.locale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: PColor.primaryColor,
              primary: PColor.primaryColor,
            ),
            scaffoldBackgroundColor: PColor.backgroundColor,
            appBarTheme: const AppBarTheme(
              backgroundColor: PColor.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            useMaterial3: true,
            fontFamily: 'Sarabun', // or system default Thai font
          ),
          home: const UserTypeSelectionPage(),
        );
      },
    );
  }
}
