// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_up_config_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FollowUpConfigState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowUpConfigState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FollowUpConfigState()';
}


}

/// @nodoc
class $FollowUpConfigStateCopyWith<$Res>  {
$FollowUpConfigStateCopyWith(FollowUpConfigState _, $Res Function(FollowUpConfigState) __);
}


/// Adds pattern-matching-related methods to [FollowUpConfigState].
extension FollowUpConfigStatePatterns on FollowUpConfigState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _ConfigLoaded value)?  configLoaded,TResult Function( _ConfigMissing value)?  configMissing,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _ConfigLoaded() when configLoaded != null:
return configLoaded(_that);case _ConfigMissing() when configMissing != null:
return configMissing(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _ConfigLoaded value)  configLoaded,required TResult Function( _ConfigMissing value)  configMissing,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _ConfigLoaded():
return configLoaded(_that);case _ConfigMissing():
return configMissing(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _ConfigLoaded value)?  configLoaded,TResult? Function( _ConfigMissing value)?  configMissing,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _ConfigLoaded() when configLoaded != null:
return configLoaded(_that);case _ConfigMissing() when configMissing != null:
return configMissing(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( FollowUpConfigEntity config)?  configLoaded,TResult Function()?  configMissing,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _ConfigLoaded() when configLoaded != null:
return configLoaded(_that.config);case _ConfigMissing() when configMissing != null:
return configMissing();case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( FollowUpConfigEntity config)  configLoaded,required TResult Function()  configMissing,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _ConfigLoaded():
return configLoaded(_that.config);case _ConfigMissing():
return configMissing();case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( FollowUpConfigEntity config)?  configLoaded,TResult? Function()?  configMissing,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _ConfigLoaded() when configLoaded != null:
return configLoaded(_that.config);case _ConfigMissing() when configMissing != null:
return configMissing();case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements FollowUpConfigState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FollowUpConfigState.initial()';
}


}




/// @nodoc


class _Loading implements FollowUpConfigState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FollowUpConfigState.loading()';
}


}




/// @nodoc


class _ConfigLoaded implements FollowUpConfigState {
  const _ConfigLoaded(this.config);
  

 final  FollowUpConfigEntity config;

/// Create a copy of FollowUpConfigState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfigLoadedCopyWith<_ConfigLoaded> get copyWith => __$ConfigLoadedCopyWithImpl<_ConfigLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfigLoaded&&(identical(other.config, config) || other.config == config));
}


@override
int get hashCode => Object.hash(runtimeType,config);

@override
String toString() {
  return 'FollowUpConfigState.configLoaded(config: $config)';
}


}

/// @nodoc
abstract mixin class _$ConfigLoadedCopyWith<$Res> implements $FollowUpConfigStateCopyWith<$Res> {
  factory _$ConfigLoadedCopyWith(_ConfigLoaded value, $Res Function(_ConfigLoaded) _then) = __$ConfigLoadedCopyWithImpl;
@useResult
$Res call({
 FollowUpConfigEntity config
});




}
/// @nodoc
class __$ConfigLoadedCopyWithImpl<$Res>
    implements _$ConfigLoadedCopyWith<$Res> {
  __$ConfigLoadedCopyWithImpl(this._self, this._then);

  final _ConfigLoaded _self;
  final $Res Function(_ConfigLoaded) _then;

/// Create a copy of FollowUpConfigState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? config = null,}) {
  return _then(_ConfigLoaded(
null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as FollowUpConfigEntity,
  ));
}


}

/// @nodoc


class _ConfigMissing implements FollowUpConfigState {
  const _ConfigMissing();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfigMissing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FollowUpConfigState.configMissing()';
}


}




/// @nodoc


class _Error implements FollowUpConfigState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of FollowUpConfigState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'FollowUpConfigState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $FollowUpConfigStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of FollowUpConfigState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
