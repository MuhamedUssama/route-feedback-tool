// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReportState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReportState()';
}


}

/// @nodoc
class $ReportStateCopyWith<$Res>  {
$ReportStateCopyWith(ReportState _, $Res Function(ReportState) __);
}


/// Adds pattern-matching-related methods to [ReportState].
extension ReportStatePatterns on ReportState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _NoConfig value)?  noConfig,TResult Function( _Ready value)?  ready,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _NoConfig() when noConfig != null:
return noConfig(_that);case _Ready() when ready != null:
return ready(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _NoConfig value)  noConfig,required TResult Function( _Ready value)  ready,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _NoConfig():
return noConfig(_that);case _Ready():
return ready(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _NoConfig value)?  noConfig,TResult? Function( _Ready value)?  ready,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _NoConfig() when noConfig != null:
return noConfig(_that);case _Ready() when ready != null:
return ready(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  noConfig,TResult Function( CycleConfigModel config,  Map<String, Map<String, int>> groupStats,  Set<String> loadingGroupNames,  String? errorMessage)?  ready,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _NoConfig() when noConfig != null:
return noConfig();case _Ready() when ready != null:
return ready(_that.config,_that.groupStats,_that.loadingGroupNames,_that.errorMessage);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  noConfig,required TResult Function( CycleConfigModel config,  Map<String, Map<String, int>> groupStats,  Set<String> loadingGroupNames,  String? errorMessage)  ready,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _NoConfig():
return noConfig();case _Ready():
return ready(_that.config,_that.groupStats,_that.loadingGroupNames,_that.errorMessage);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  noConfig,TResult? Function( CycleConfigModel config,  Map<String, Map<String, int>> groupStats,  Set<String> loadingGroupNames,  String? errorMessage)?  ready,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _NoConfig() when noConfig != null:
return noConfig();case _Ready() when ready != null:
return ready(_that.config,_that.groupStats,_that.loadingGroupNames,_that.errorMessage);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements ReportState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReportState.initial()';
}


}




/// @nodoc


class _Loading implements ReportState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReportState.loading()';
}


}




/// @nodoc


class _NoConfig implements ReportState {
  const _NoConfig();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoConfig);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ReportState.noConfig()';
}


}




/// @nodoc


class _Ready implements ReportState {
  const _Ready({required this.config, required final  Map<String, Map<String, int>> groupStats, final  Set<String> loadingGroupNames = const {}, this.errorMessage}): _groupStats = groupStats,_loadingGroupNames = loadingGroupNames;
  

 final  CycleConfigModel config;
 final  Map<String, Map<String, int>> _groupStats;
 Map<String, Map<String, int>> get groupStats {
  if (_groupStats is EqualUnmodifiableMapView) return _groupStats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_groupStats);
}

// key: groupName, val: {submitted: 0, etc}
 final  Set<String> _loadingGroupNames;
// key: groupName, val: {submitted: 0, etc}
@JsonKey() Set<String> get loadingGroupNames {
  if (_loadingGroupNames is EqualUnmodifiableSetView) return _loadingGroupNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_loadingGroupNames);
}

 final  String? errorMessage;

/// Create a copy of ReportState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadyCopyWith<_Ready> get copyWith => __$ReadyCopyWithImpl<_Ready>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ready&&(identical(other.config, config) || other.config == config)&&const DeepCollectionEquality().equals(other._groupStats, _groupStats)&&const DeepCollectionEquality().equals(other._loadingGroupNames, _loadingGroupNames)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,config,const DeepCollectionEquality().hash(_groupStats),const DeepCollectionEquality().hash(_loadingGroupNames),errorMessage);

@override
String toString() {
  return 'ReportState.ready(config: $config, groupStats: $groupStats, loadingGroupNames: $loadingGroupNames, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$ReadyCopyWith<$Res> implements $ReportStateCopyWith<$Res> {
  factory _$ReadyCopyWith(_Ready value, $Res Function(_Ready) _then) = __$ReadyCopyWithImpl;
@useResult
$Res call({
 CycleConfigModel config, Map<String, Map<String, int>> groupStats, Set<String> loadingGroupNames, String? errorMessage
});




}
/// @nodoc
class __$ReadyCopyWithImpl<$Res>
    implements _$ReadyCopyWith<$Res> {
  __$ReadyCopyWithImpl(this._self, this._then);

  final _Ready _self;
  final $Res Function(_Ready) _then;

/// Create a copy of ReportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? config = null,Object? groupStats = null,Object? loadingGroupNames = null,Object? errorMessage = freezed,}) {
  return _then(_Ready(
config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as CycleConfigModel,groupStats: null == groupStats ? _self._groupStats : groupStats // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, int>>,loadingGroupNames: null == loadingGroupNames ? _self._loadingGroupNames : loadingGroupNames // ignore: cast_nullable_to_non_nullable
as Set<String>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Error implements ReportState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of ReportState
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
  return 'ReportState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $ReportStateCopyWith<$Res> {
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

/// Create a copy of ReportState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
