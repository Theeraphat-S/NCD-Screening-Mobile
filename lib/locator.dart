import 'package:get_it/get_it.dart';
import 'package:mobile_app_standard/domain/datasource/app_datebase.dart';
import 'package:mobile_app_standard/domain/http_client/ip.dart';
import 'package:mobile_app_standard/domain/http_client/websocket.dart';
import 'package:mobile_app_standard/domain/repositories/drift_ncd_repository.dart';
import 'package:mobile_app_standard/domain/repositories/ncd_repository.dart';
import 'package:mobile_app_standard/domain/repositories/todo_repo.dart';
import 'package:mobile_app_standard/domain/services/pdf_report_service.dart';
import 'package:mobile_app_standard/domain/services/sync_queue_service.dart';
import 'package:mobile_app_standard/feature/auth/bloc/auth_bloc.dart';
import 'package:mobile_app_standard/shared/bloc/accessibility/accessibility_cubit.dart';
import 'package:mobile_app_standard/shared/bloc/sync_badge_bloc.dart';
import 'package:mobile_app_standard/feature/home/bloc/websocket/websocket_bloc.dart';
import 'package:mobile_app_standard/feature/nurse/bloc/village_analytics_bloc.dart';
import 'package:mobile_app_standard/feature/nurse/bloc/village_bloc.dart';
import 'package:mobile_app_standard/feature/patient/bloc/patient_bloc.dart';
import 'package:mobile_app_standard/feature/screening/bloc/screening_bloc.dart';
import 'package:mobile_app_standard/feature/todo/bloc/todo_bloc.dart';
import 'package:mobile_app_standard/feature/vhv/bloc/vhv_bloc.dart';
import 'package:mobile_app_standard/shared/bloc/language/language_bloc.dart';

final locator = GetIt.instance;

Future<void> initLocator() async {
  // Register AppDatabase
  locator.registerLazySingleton<AppDatabase>(AppDatabase.new);

  // Register NCD Repository (Offline-first Drift SQLite database persistence)
  locator.registerLazySingleton<NcdRepositoryInterface>(
      () => DriftNcdRepository(locator<AppDatabase>()));

  // Register PDF Report Service
  locator.registerLazySingleton<PdfReportServiceInterface>(PdfReportService.new);

  // Register Sync Queue Service
  locator.registerLazySingleton<SyncQueueServiceInterface>(SyncQueueService.new);

  // Register Legacy Repository
  locator.registerLazySingleton<TodoRepositoryInterface>(
      () => TodoRepository(locator<AppDatabase>()));

  // Register HttpClient
  locator.registerLazySingleton<IpClient>(IpClient.new);

  // Register WebSocketClient
  locator.registerLazySingleton<WebSocketClient>(WebSocketClient.new);

  // Register NCD BLoCs
  locator.registerLazySingleton<AuthBloc>(
      () => AuthBloc(locator<NcdRepositoryInterface>()));
  locator.registerLazySingleton<PatientBloc>(
      () => PatientBloc(locator<NcdRepositoryInterface>()));
  locator.registerLazySingleton<ScreeningBloc>(
      () => ScreeningBloc(locator<NcdRepositoryInterface>()));
  locator.registerLazySingleton<VhvBloc>(
      () => VhvBloc(locator<NcdRepositoryInterface>()));
  locator.registerLazySingleton<VillageBloc>(
      () => VillageBloc(locator<NcdRepositoryInterface>()));
  locator.registerLazySingleton<VillageAnalyticsBloc>(
      () => VillageAnalyticsBloc(locator<NcdRepositoryInterface>()));
  locator.registerLazySingleton<SyncBadgeBloc>(
      () => SyncBadgeBloc(syncService: locator<SyncQueueServiceInterface>()));
  locator.registerLazySingleton<AccessibilityCubit>(AccessibilityCubit.new);

  // Register Misc Blocs
  locator.registerLazySingleton<TodoBloc>(TodoBloc.new);
  locator.registerLazySingleton<WebsocketBloc>(WebsocketBloc.new);
  locator.registerLazySingleton<LanguageBloc>(LanguageBloc.new);
}
