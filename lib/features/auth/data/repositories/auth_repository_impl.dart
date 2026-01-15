import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/auth_error_type.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      final (user, _) = await _remoteDataSource.loginWithGoogle();
      await _localDataSource.cacheUser(user);

      return Right(user);
    } on GoogleAuthException catch (e) {
      return Left(Failure.auth(e.message, e.type));
    } on ServerException catch (e) {
      return Left(Failure.server(e.message, statusCode: e.statusCode));
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    } on TypeError catch (e, stackTrace) {
      if (kDebugMode) {
        print("❌ Parsing Error: $e \nStack: $stackTrace");
      }
      return const Left(Failure.server('Unable to process user data'));
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("❌ Unexpected Error in AuthRepository: $e \nStack: $stackTrace");
      }
      return Left(Failure.server(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.signOut();
      await _localDataSource.clearUserCache();
      return const Right(null);
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCachedUser() async {
    try {
      final userModel = await _localDataSource.getCachedUser();
      return Right(userModel);
    } on CacheException catch (e) {
      return Left(Failure.cache(e.message));
    } catch (e) {
      return Left(Failure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> checkAutoLogin() async {
    try {
      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser == null) {
        return const Left(
          Failure.auth('No cached user', AuthErrorType.userNotAuthenticated),
        );
      }

      final user = await _remoteDataSource.loginSilently(null);

      if (user != null) {
        await _localDataSource.cacheUser(user);
        return Right(user);
      } else {
        await _localDataSource.clearUserCache();
        return const Left(
          Failure.auth(
            'Silent login failed',
            AuthErrorType.userNotAuthenticated,
          ),
        );
      }
    } catch (e) {
      await _localDataSource.clearUserCache();
      return Left(Failure.unexpected(e.toString()));
    }
  }
}
