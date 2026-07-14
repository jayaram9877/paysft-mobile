import 'package:get_it/get_it.dart';
import 'package:buyer/presentation/providers/app_version_provider.dart';
import 'package:buyer/presentation/providers/onboarding_provider.dart';
import '../../data/datasources/remote/app_version_remote_data_source.dart';
import '../../data/repositories/app_version_repository_impl.dart';
import '../../data/datasources/remote/auth_remote_data_source.dart';
import '../../data/datasources/remote/onboarding_remote_data_source.dart';
import '../../data/datasources/remote/profile_remote_data_source.dart';
import '../../data/datasources/remote/lead_remote_data_source.dart';
import '../../data/datasources/remote/chat_remote_data_source.dart';
import '../../presentation/providers/chat_list_provider.dart';
import '../../data/datasources/remote/saved_units_remote_data_source.dart';
import '../../data/datasources/remote/sales_remote_data_source.dart';
import '../../data/datasources/remote/visits_remote_data_source.dart';
import '../../data/datasources/remote/notifications_remote_data_source.dart';
import '../../presentation/providers/profile_provider.dart';
import '../../presentation/providers/lead_provider.dart';
import '../../presentation/providers/saved_units_provider.dart';
import '../../presentation/providers/notifications_provider.dart';
import '../../presentation/providers/offers_provider.dart';
import '../../presentation/providers/visits_provider.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/repositories/app_version_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/usecases/get_onboarding_content.dart';
import '../../domain/usecases/verify_app_version.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../domain/usecases/signup_buyer.dart';
import '../../domain/usecases/verify_contact.dart';
import '../../domain/usecases/resend_signup_otp.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/signup_provider.dart';
import '../../presentation/providers/home_provider.dart';
import '../../presentation/providers/filter_provider.dart';
import '../../presentation/providers/property_details_provider.dart';
import '../../presentation/providers/search_provider.dart';
import '../services/social_auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/device_identity_service.dart';
import '../../domain/repositories/home_repository.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../data/datasources/home_local_data_source.dart';
import '../../data/datasources/remote/home_remote_data_source.dart';
import '../../domain/repositories/property_details_repository.dart';
import '../../data/repositories/property_details_repository_impl.dart';
import '../../data/datasources/property_details_local_data_source.dart';
import '../../data/datasources/remote/property_details_remote_data_source.dart';
import '../config/app_flavor.dart';
import '../services/location_service.dart';
import '../../domain/repositories/location_repository.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../presentation/providers/location_provider.dart';
import '../../presentation/providers/pay_token_provider.dart';
import '../../presentation/providers/favorites_provider.dart';
import '../../presentation/providers/agent_profile_provider.dart';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

Future<void> init([AppConfig? config]) async {
  // Register app config if provided
  if (config != null) {
    sl.registerLazySingleton<AppConfig>(() => config);
  }
  // Features - Auth
  // Providers
  sl.registerFactory(
    () => AuthProvider(
      sendOTP: sl(),
      verifyOTP: sl(),
      localStorageService: sl(),
    ),
  );
  sl.registerFactory(
    () => SignupProvider(
      signupBuyer: sl(),
      verifyContactUseCase: sl(),
      resendSignupOtp: sl(),
      localStorageService: sl(),
    ),
  );
  sl.registerFactory(
    () => ProfileProvider(dataSource: sl(), localStorageService: sl()),
  );
  sl.registerFactory(() => AppVersionProvider(verifyAppVersion: sl()));
  sl.registerFactory(() => OnboardingProvider(getOnboardingContent: sl()));
  sl.registerFactory(() => HomeProvider(homeRepository: sl()));
  sl.registerFactory(() => FilterProvider());
  sl.registerFactory(() => PropertyDetailsProvider(repository: sl()));
  sl.registerFactory(() => SearchProvider(homeRepository: sl()));
  sl.registerFactory(() => FavoritesProvider(dataSource: sl()));
  sl.registerLazySingleton(
    () => LocationProvider(
      locationService: sl(),
      locationRepository: sl(),
      localStorageService: sl(),
      homeRepository: sl(),
    ),
  );

  sl.registerFactory(() => PayTokenProvider());
  sl.registerFactory(
    () => ChatListProvider(chatDataSource: sl(), leadDataSource: sl()),
  );
  sl.registerFactory(() => AgentProfileProvider());
  // App-wide singletons so unit cards + unit details + favorites share state.
  sl.registerLazySingleton(() => LeadProvider(dataSource: sl()));
  sl.registerLazySingleton(() => SavedUnitsProvider(dataSource: sl()));
  sl.registerLazySingleton(() => VisitsProvider(dataSource: sl()));
  sl.registerLazySingleton(() => OffersProvider(dataSource: sl()));
  sl.registerLazySingleton(
    () => NotificationsProvider(dataSource: sl(), storage: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SendOTP(sl()));
  sl.registerLazySingleton(() => VerifyOTP(sl()));
  sl.registerLazySingleton(() => SignupBuyer(sl()));
  sl.registerLazySingleton(() => VerifyContact(sl()));
  sl.registerLazySingleton(() => ResendSignupOtp(sl()));
  sl.registerLazySingleton(() => VerifyAppVersion(sl()));
  sl.registerLazySingleton(() => GetOnboardingContent(sl()));

  // Network
  sl.registerLazySingleton<Dio>(() => DioClient.create(sl<AppConfig>()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AppVersionRepository>(
    () => AppVersionRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PropertyDetailsRepository>(
    () => PropertyDetailsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl());

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl(), apiClient: sl()),
  );
  sl.registerLazySingleton<AppVersionRemoteDataSource>(
    () => AppVersionRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<LeadRemoteDataSource>(
    () => LeadRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<SavedUnitsRemoteDataSource>(
    () => SavedUnitsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<VisitsRemoteDataSource>(
    () => VisitsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<SalesRemoteDataSource>(
    () => SalesRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<PropertyDetailsLocalDataSource>(
    () => PropertyDetailsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<PropertyDetailsRemoteDataSource>(
    () => PropertyDetailsRemoteDataSourceImpl(dio: sl(), defaults: sl()),
  );

  // Services
  sl.registerLazySingleton(() => SocialAuthService());
  sl.registerLazySingleton(() => LocalStorageService());
  sl.registerLazySingleton(() => LocationService());
  sl.registerLazySingleton(() => DeviceIdentityService());
}
