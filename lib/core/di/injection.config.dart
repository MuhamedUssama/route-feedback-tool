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
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/follow_up/data/datasources/follow_up_local_data_source.dart'
    as _i1015;
import '../../features/follow_up/data/datasources/gmail_remote_data_source.dart'
    as _i962;
import '../../features/follow_up/data/datasources/sheets_remote_data_source.dart'
    as _i850;
import '../../features/follow_up/data/repositories/follow_up_repository_impl.dart'
    as _i826;
import '../../features/follow_up/domain/repositories/follow_up_repository.dart'
    as _i934;
import '../../features/follow_up/domain/usecases/check_missing_assignments_usecase.dart'
    as _i306;
import '../../features/follow_up/domain/usecases/get_follow_up_config_usecase.dart'
    as _i68;
import '../../features/follow_up/domain/usecases/get_sheet_headers_usecase.dart'
    as _i578;
import '../../features/follow_up/domain/usecases/save_follow_up_config_usecase.dart'
    as _i265;
import '../../features/follow_up/domain/usecases/send_follow_up_email_usecase.dart'
    as _i847;
import '../../features/follow_up/domain/usecases/update_student_status_usecase.dart'
    as _i880;
import '../../features/follow_up/presentation/cubits/follow_up_action/follow_up_action_cubit.dart'
    as _i20;
import '../../features/follow_up/presentation/cubits/follow_up_config/follow_up_config_cubit.dart'
    as _i268;
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
    gh.lazySingleton<_i1015.FollowUpLocalDataSource>(
      () => _i1015.FollowUpLocalDataSourceImpl(gh<_i816.SharedPrefsService>()),
    );
    gh.lazySingleton<_i852.AuthLocalDataSource>(
      () => _i852.AuthLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i850.SheetsRemoteDataSource>(
      () => _i850.SheetsRemoteDataSourceImpl(gh<_i527.GoogleAuthClient>()),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.AuthRemoteDataSourceImpl(gh<_i527.GoogleAuthClient>()),
    );
    gh.lazySingleton<_i962.GmailRemoteDataSource>(
      () => _i962.GmailRemoteDataSourceImpl(gh<_i527.GoogleAuthClient>()),
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
    gh.lazySingleton<_i934.FollowUpRepository>(
      () => _i826.FollowUpRepositoryImpl(
        gh<_i850.SheetsRemoteDataSource>(),
        gh<_i962.GmailRemoteDataSource>(),
        gh<_i1015.FollowUpLocalDataSource>(),
      ),
    );
    gh.factory<_i117.AuthCubit>(
      () => _i117.AuthCubit(gh<_i57.LoginWithGoogleUseCase>()),
    );
    gh.lazySingleton<_i306.CheckMissingAssignmentsUseCase>(
      () =>
          _i306.CheckMissingAssignmentsUseCase(gh<_i934.FollowUpRepository>()),
    );
    gh.lazySingleton<_i68.GetFollowUpConfigUseCase>(
      () => _i68.GetFollowUpConfigUseCase(gh<_i934.FollowUpRepository>()),
    );
    gh.lazySingleton<_i578.GetSheetHeadersUseCase>(
      () => _i578.GetSheetHeadersUseCase(gh<_i934.FollowUpRepository>()),
    );
    gh.lazySingleton<_i265.SaveFollowUpConfigUseCase>(
      () => _i265.SaveFollowUpConfigUseCase(gh<_i934.FollowUpRepository>()),
    );
    gh.lazySingleton<_i847.SendFollowUpEmailUseCase>(
      () => _i847.SendFollowUpEmailUseCase(gh<_i934.FollowUpRepository>()),
    );
    gh.lazySingleton<_i880.UpdateStudentStatusUseCase>(
      () => _i880.UpdateStudentStatusUseCase(gh<_i934.FollowUpRepository>()),
    );
    gh.factory<_i268.FollowUpConfigCubit>(
      () => _i268.FollowUpConfigCubit(
        gh<_i68.GetFollowUpConfigUseCase>(),
        gh<_i265.SaveFollowUpConfigUseCase>(),
      ),
    );
    gh.factory<_i20.FollowUpActionCubit>(
      () => _i20.FollowUpActionCubit(
        gh<_i578.GetSheetHeadersUseCase>(),
        gh<_i306.CheckMissingAssignmentsUseCase>(),
        gh<_i847.SendFollowUpEmailUseCase>(),
        gh<_i880.UpdateStudentStatusUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
