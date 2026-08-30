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
import 'package:mobile_app_standard/feature/vhv/bloc/vhv_bloc.dart';
import 'package:mobile_app_standard/i18n/i18n.dart';
import 'package:mobile_app_standard/locator.dart';
import 'package:mobile_app_standard/shared/bloc/accessibility/accessibility_cubit.dart';
import 'package:mobile_app_standard/shared/bloc/language/language_bloc.dart';
import 'package:mobile_app_standard/shared/bloc/language/language_state.dart';
import 'package:mobile_app_standard/shared/bloc/sync_badge_bloc.dart';
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
        BlocProvider<SyncBadgeBloc>(
          create: (context) => locator<SyncBadgeBloc>()..add(const SyncBadgeStarted()),
        ),
        BlocProvider<AccessibilityCubit>(create: (context) => locator<AccessibilityCubit>()),
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
              secondary: PColor.secondaryColor,
              surface: PColor.neutralColor,
              error: PColor.errorColor,
            ),
            scaffoldBackgroundColor: PColor.backgroundColor,
            appBarTheme: const AppBarTheme(
              backgroundColor: PColor.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontFamily: 'Sarabun',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: PColor.borderSubtle, width: 1),
              ),
              margin: EdgeInsets.zero,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PColor.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PColor.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PColor.primaryColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PColor.errorColor),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: PColor.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Sarabun',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            useMaterial3: true,
            fontFamily: 'Sarabun',
          ),
          home: const UserTypeSelectionPage(),
        );
      },
    );
  }
}
