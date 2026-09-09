// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'splash_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SplashState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SplashState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SplashState()';
}


}

/// @nodoc
class $SplashStateCopyWith<$Res>  {
$SplashStateCopyWith(SplashState _, $Res Function(SplashState) __);
}


/// Adds pattern-matching-related methods to [SplashState].
extension SplashStatePatterns on SplashState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SplashInitial value)?  initial,TResult Function( SplashLoading value)?  loading,TResult Function( AuthAuthenticated value)?  authenticated,TResult Function( AuthUnauthenticated value)?  unauthenticated,TResult Function( SplashError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SplashInitial() when initial != null:
return initial(_that);case SplashLoading() when loading != null:
return loading(_that);case AuthAuthenticated() when authenticated != null:
return authenticated(_that);case AuthUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case SplashError() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SplashInitial value)  initial,required TResult Function( SplashLoading value)  loading,required TResult Function( AuthAuthenticated value)  authenticated,required TResult Function( AuthUnauthenticated value)  unauthenticated,required TResult Function( SplashError value)  error,}){
final _that = this;
switch (_that) {
case SplashInitial():
return initial(_that);case SplashLoading():
return loading(_that);case AuthAuthenticated():
return authenticated(_that);case AuthUnauthenticated():
return unauthenticated(_that);case SplashError():
return error(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SplashInitial value)?  initial,TResult? Function( SplashLoading value)?  loading,TResult? Function( AuthAuthenticated value)?  authenticated,TResult? Function( AuthUnauthenticated value)?  unauthenticated,TResult? Function( SplashError value)?  error,}){
final _that = this;
switch (_that) {
case SplashInitial() when initial != null:
return initial(_that);case SplashLoading() when loading != null:
return loading(_that);case AuthAuthenticated() when authenticated != null:
return authenticated(_that);case AuthUnauthenticated() when unauthenticated != null:
return unauthenticated(_that);case SplashError() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( String message,  double progress)?  loading,TResult Function( UserEntity user)?  authenticated,TResult Function()?  unauthenticated,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SplashInitial() when initial != null:
return initial();case SplashLoading() when loading != null:
return loading(_that.message,_that.progress);case AuthAuthenticated() when authenticated != null:
return authenticated(_that.user);case AuthUnauthenticated() when unauthenticated != null:
return unauthenticated();case SplashError() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( String message,  double progress)  loading,required TResult Function( UserEntity user)  authenticated,required TResult Function()  unauthenticated,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case SplashInitial():
return initial();case SplashLoading():
return loading(_that.message,_that.progress);case AuthAuthenticated():
return authenticated(_that.user);case AuthUnauthenticated():
return unauthenticated();case SplashError():
return error(_that.message);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( String message,  double progress)?  loading,TResult? Function( UserEntity user)?  authenticated,TResult? Function()?  unauthenticated,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case SplashInitial() when initial != null:
return initial();case SplashLoading() when loading != null:
return loading(_that.message,_that.progress);case AuthAuthenticated() when authenticated != null:
return authenticated(_that.user);case AuthUnauthenticated() when unauthenticated != null:
return unauthenticated();case SplashError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class SplashInitial implements SplashState {
  const SplashInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SplashInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SplashState.initial()';
}


}




/// @nodoc


class SplashLoading implements SplashState {
  const SplashLoading({this.message = 'Initializing...', this.progress = 0.0});
  

@JsonKey() final  String message;
@JsonKey() final  double progress;

/// Create a copy of SplashState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SplashLoadingCopyWith<SplashLoading> get copyWith => _$SplashLoadingCopyWithImpl<SplashLoading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SplashLoading&&(identical(other.message, message) || other.message == message)&&(identical(other.progress, progress) || other.progress == progress));
}


@override
int get hashCode => Object.hash(runtimeType,message,progress);

@override
String toString() {
  return 'SplashState.loading(message: $message, progress: $progress)';
}


}

/// @nodoc
abstract mixin class $SplashLoadingCopyWith<$Res> implements $SplashStateCopyWith<$Res> {
  factory $SplashLoadingCopyWith(SplashLoading value, $Res Function(SplashLoading) _then) = _$SplashLoadingCopyWithImpl;
@useResult
$Res call({
 String message, double progress
});




}
/// @nodoc
class _$SplashLoadingCopyWithImpl<$Res>
    implements $SplashLoadingCopyWith<$Res> {
  _$SplashLoadingCopyWithImpl(this._self, this._then);

  final SplashLoading _self;
  final $Res Function(SplashLoading) _then;

/// Create a copy of SplashState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? progress = null,}) {
  return _then(SplashLoading(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class AuthAuthenticated implements SplashState {
  const AuthAuthenticated(this.user);
  

 final  UserEntity user;

/// Create a copy of SplashState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthAuthenticatedCopyWith<AuthAuthenticated> get copyWith => _$AuthAuthenticatedCopyWithImpl<AuthAuthenticated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthAuthenticated&&(identical(other.user, user) || other.user == user));
}


@override
int get hashCode => Object.hash(runtimeType,user);

@override
String toString() {
  return 'SplashState.authenticated(user: $user)';
}


}

/// @nodoc
abstract mixin class $AuthAuthenticatedCopyWith<$Res> implements $SplashStateCopyWith<$Res> {
  factory $AuthAuthenticatedCopyWith(AuthAuthenticated value, $Res Function(AuthAuthenticated) _then) = _$AuthAuthenticatedCopyWithImpl;
@useResult
$Res call({
 UserEntity user
});




}
/// @nodoc
class _$AuthAuthenticatedCopyWithImpl<$Res>
    implements $AuthAuthenticatedCopyWith<$Res> {
  _$AuthAuthenticatedCopyWithImpl(this._self, this._then);

  final AuthAuthenticated _self;
  final $Res Function(AuthAuthenticated) _then;

/// Create a copy of SplashState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,}) {
  return _then(AuthAuthenticated(
null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserEntity,
  ));
}


}

/// @nodoc


class AuthUnauthenticated implements SplashState {
  const AuthUnauthenticated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUnauthenticated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SplashState.unauthenticated()';
}


}




/// @nodoc


class SplashError implements SplashState {
  const SplashError(this.message);
  

 final  String message;

/// Create a copy of SplashState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SplashErrorCopyWith<SplashError> get copyWith => _$SplashErrorCopyWithImpl<SplashError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SplashError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SplashState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $SplashErrorCopyWith<$Res> implements $SplashStateCopyWith<$Res> {
  factory $SplashErrorCopyWith(SplashError value, $Res Function(SplashError) _then) = _$SplashErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SplashErrorCopyWithImpl<$Res>
    implements $SplashErrorCopyWith<$Res> {
  _$SplashErrorCopyWithImpl(this._self, this._then);

  final SplashError _self;
  final $Res Function(SplashError) _then;

/// Create a copy of SplashState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SplashError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
