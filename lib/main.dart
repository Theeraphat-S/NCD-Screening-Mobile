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
import 'package:mobile_app_standard/shared/theme/app_theme.dart';

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
        return BlocBuilder<AccessibilityCubit, AccessibilityState>(
          builder: (context, accessState) {
            return MaterialApp(
              title: 'NCD Screening Mobile',
              debugShowCheckedModeBanner: false,
              supportedLocales: I18n.all,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              locale: languageState.locale,
              theme: accessState.isHighContrast
                  ? AppTheme.highContrastTheme
                  : AppTheme.standardTheme,
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                final systemScale = mediaQuery.textScaler.scale(1.0);
                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.linear(systemScale * accessState.textScaleFactor),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
              home: const UserTypeSelectionPage(),
            );
          },
        );
      },
    );
  }
}
