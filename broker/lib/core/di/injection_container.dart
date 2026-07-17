import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../data/datasources/remote/auth_remote_data_source.dart';
import '../../data/datasources/remote/broker_auth_remote_data_source.dart';
import '../../data/datasources/remote/broker_kyc_remote_data_source.dart';
import '../../data/datasources/remote/broker_dashboard_remote_data_source.dart';
import '../../data/datasources/remote/broker_projects_remote_data_source.dart';
import '../../data/datasources/remote/broker_assignments_remote_data_source.dart';
import '../../data/datasources/remote/broker_visits_remote_data_source.dart';
import '../../data/datasources/remote/chat_remote_data_source.dart';
import '../../presentation/providers/chat_list_provider.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/broker_auth_provider.dart';
import '../../presentation/providers/broker_kyc_provider.dart';
import '../../presentation/providers/home_dashboard_provider.dart';
import '../../presentation/providers/projects_provider.dart';
import '../../presentation/providers/project_detail_provider.dart';
import '../../presentation/providers/profile_provider.dart';
import '../../presentation/providers/broker_documents_provider.dart';
import '../../presentation/providers/schedule_provider.dart';
import '../../presentation/providers/client_schedule_provider.dart';
import '../network/dio_client.dart';
import '../services/local_storage_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Auth
  // Providers
  sl.registerFactory(
    () => AuthProvider(sendOTP: sl(), verifyOTP: sl(), localStorageService: sl()),
  );
  sl.registerFactory(
    () => BrokerAuthProvider(remoteDataSource: sl(), localStorageService: sl()),
  );
  sl.registerFactory(() => BrokerKycProvider(remoteDataSource: sl()));
  sl.registerFactory(() => HomeDashboardProvider(remoteDataSource: sl()));
  sl.registerFactory(
    () => ProjectsProvider(
      remoteDataSource: sl(),
      assignmentsDataSource: sl(),
    ),
  );
  sl.registerFactory(() => ProjectDetailProvider(remoteDataSource: sl()));
  sl.registerLazySingleton(
    () => ChatListProvider(assignmentsDataSource: sl(), chatDataSource: sl()),
  );
  sl.registerFactory(() => BrokerDocumentsProvider(remoteDataSource: sl()));
  sl.registerFactory(
    () => ScheduleProvider(visitsDataSource: sl(), projectsDataSource: sl()),
  );
  sl.registerFactory(() => ClientScheduleProvider(visitsDataSource: sl()));
  sl.registerFactory(
    () => ProfileProvider(
      authDataSource: sl(),
      kycDataSource: sl(),
      localStorageService: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SendOTP(sl()));
  sl.registerLazySingleton(() => VerifyOTP(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<BrokerAuthRemoteDataSource>(
    () => BrokerAuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BrokerKycRemoteDataSource>(
    () => BrokerKycRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BrokerDashboardRemoteDataSource>(
    () => BrokerDashboardRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BrokerProjectsRemoteDataSource>(
    () => BrokerProjectsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BrokerAssignmentsRemoteDataSource>(
    () => BrokerAssignmentsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BrokerVisitsRemoteDataSource>(
    () => BrokerVisitsRemoteDataSourceImpl(sl()),
  );

  // Core / network
  sl.registerLazySingleton<Dio>(
    () => DioClient.create(localStorageService: sl()),
  );

  // Services
  sl.registerLazySingleton(() => LocalStorageService());
}
