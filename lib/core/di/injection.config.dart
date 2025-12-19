// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_local_data_source.dart'
    as _i852;
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_cached_user_usecase.dart'
    as _i389;
import '../../features/auth/domain/usecases/login_with_google_usecase.dart'
    as _i57;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../network/google_auth_client.dart' as _i527;
import '../services/shared_prefs_service.dart' as _i816;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i527.GoogleAuthClient>(() => _i527.GoogleAuthClient());
    gh.lazySingleton<_i816.SharedPrefsService>(
      () => _i816.SharedPrefsService(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i852.AuthLocalDataSource>(
      () => _i852.AuthLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.AuthRemoteDataSourceImpl(gh<_i527.GoogleAuthClient>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i107.AuthRemoteDataSource>(),
        gh<_i852.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i389.GetCachedUserUseCase>(
      () => _i389.GetCachedUserUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i57.LoginWithGoogleUseCase>(
      () => _i57.LoginWithGoogleUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i48.LogoutUseCase>(
      () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
