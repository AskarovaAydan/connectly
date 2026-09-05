import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectly/features/post/data/datasource/post_remote_datasource.dart';
import 'package:connectly/features/post/data/repository/post_repository_impl.dart';
import 'package:connectly/features/post/domain/repositories/post_repository.dart';
import 'package:connectly/features/post/domain/usecases/create_post_usecase.dart';
import 'package:connectly/features/post/domain/usecases/get_posts_usecase.dart';
import 'package:connectly/features/post/domain/usecases/toggle_like_usecase.dart';
import 'package:connectly/features/post/presentation/cubit/post_cubit.dart';
import 'package:connectly/features/profile/data/datasource/profile_remote_datasource.dart';
import 'package:connectly/features/profile/data/repository/profile_repository_impl.dart';
import 'package:connectly/features/profile/domain/repositories/profile_repository.dart';
import 'package:connectly/features/profile/domain/usecases/create_profile_usecase.dart';
import 'package:connectly/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:connectly/features/auth/domain/usecases/login_usecase.dart';
import 'package:connectly/features/auth/domain/usecases/logout_usecase.dart';
import 'package:connectly/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasource/auth_remote_datasource.dart';
import '../../features/auth/data/repository/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

final getIt = GetIt.instance; //get it anbaranin singletonu

void setupInjections() {
  //siralamaya diqqet edirik yuxardan asagiya
  // Firebase
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  //registerLazySingleton — "bu tipdən bir dəfə obyekt yarat, sonra hər sorğuda eyni obyekti qaytar" (yaddaş qənaəti üçün)
  //Lazy — obyekt dərhal yaranmır, yalnız ilk dəfə kimsə getIt<...>() çağıranda yaranır
  //<Tip> — hansı tip üçün qeydiyyatdan keçirdiyimizi göstərir (məsələn <AuthRepository>)

  // DataSource
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<FirebaseAuth>()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
    ), //Yəni GetIt-ə deyirsən:Kimsə AuthRepository istəsə, ona AuthRepositoryImpl ver.
  );

  // UseCase
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );

  // Cubit
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      getIt<RegisterUseCase>(),
      getIt<LoginUseCase>(),
      getIt<LogoutUseCase>(),
    ),
  ); //burada registerLazySingleton yox, registerFactory işlədirik. Fərqi izah edim: Cubit-lər hər dəfə təzə yaranmalıdır (məsələn səhifədən çıxıb yenidən girəndə state təmiz olsun), ona görə Factory işlədirik ki, hər çağırışda yeni obyekt yaransın (Singleton kimi "bir dəfə yarat, təkrar istifadə et" olmasın).

  // Firestore + Storage
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Profile DataSource
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(
      getIt<FirebaseFirestore>(),
      getIt<FirebaseStorage>(),
    ),
  );

  // Profile Repository
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
  );

  // Profile UseCases
  getIt.registerLazySingleton<CreateProfileUseCase>(
    () => CreateProfileUseCase(getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(getIt<ProfileRepository>()),
  );
  //Cubit
  getIt.registerFactory<ProfileCubit>(
    () =>
        ProfileCubit(getIt<CreateProfileUseCase>(), getIt<GetProfileUseCase>()),
  );
  // Post DataSource
  getIt.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSource(getIt<FirebaseFirestore>()),
  );

  // Post Repository
  getIt.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(getIt<PostRemoteDataSource>()),
  );

  // Post UseCases
  getIt.registerLazySingleton<CreatePostUseCase>(
    () => CreatePostUseCase(getIt<PostRepository>()),
  );
  getIt.registerLazySingleton<GetPostsUseCase>(
    () => GetPostsUseCase(getIt<PostRepository>()),
  );
  getIt.registerLazySingleton<ToggleLikeUseCase>(
    () => ToggleLikeUseCase(getIt<PostRepository>()),
  );
  //Cubit
  getIt.registerFactory<PostCubit>(
    () => PostCubit(
      getIt<CreatePostUseCase>(),
      getIt<GetPostsUseCase>(),
      getIt<ToggleLikeUseCase>(),
    ),
  );
} 


/*
Sən artıq bir GetIt container/anbar yaradırsan:

getIt
 │
 ├── FirebaseAuth
 ├── AuthRemoteDataSource
 ├── AuthRepository
 ├── RegisterUseCase
 ├── LoginUseCase
 ├── LogoutUseCase
 └── AuthCubit
bu fayl bu elaqeleri qurur
Sonra hər yerdə:

getIt<Type>()

ilə həmin anbarın içindən dependency götürürsən.


GetIt:

getIt<AuthRepository>()

deyəndə:

AuthRepository
     ↓
AuthRepositoryImpl
     ↓
AuthRemoteDataSource
     ↓
FirebaseAuth

əlaqəsini bilir.



LoginUseCase

Eyni şey:

getIt.registerLazySingleton<LoginUseCase>(
  () => LoginUseCase(
    getIt<AuthRepository>(),
  ),
);
LoginUseCase
     ↓
AuthRepository
     ↓
AuthRepositoryImpl
     ↓
AuthRemoteDataSource
     ↓
FirebaseAuth



Bütün kodun arxasında əslində bu var

Sən yazmısan:

getIt.registerFactory<AuthCubit>(
  () => AuthCubit(
    getIt<RegisterUseCase>(),
    getIt<LoginUseCase>(),
    getIt<LogoutUseCase>(),
  ),
);

Amma bunu GetIt olmadan əl ilə etsəydin, təxminən belə olardı:

final firebaseAuth = FirebaseAuth.instance;

final dataSource = AuthRemoteDataSource(
  firebaseAuth,
);

final repository = AuthRepositoryImpl(
  dataSource,
);

final registerUseCase = RegisterUseCase(
  repository,
);

final loginUseCase = LoginUseCase(
  repository,
);

final logoutUseCase = LogoutUseCase(
  repository,
);

final cubit = AuthCubit(
  registerUseCase,
  loginUseCase,
  logoutUseCase,
);

GetIt-in məqsədi məhz bu dependency-lərin yaradılmasını və tapılmasını mərkəzləşdirməkdir.
*/