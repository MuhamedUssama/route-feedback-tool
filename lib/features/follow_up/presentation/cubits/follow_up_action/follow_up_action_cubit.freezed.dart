// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_up_action_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FollowUpActionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowUpActionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FollowUpActionState()';
}


}

/// @nodoc
class $FollowUpActionStateCopyWith<$Res>  {
$FollowUpActionStateCopyWith(FollowUpActionState _, $Res Function(FollowUpActionState) __);
}


/// Adds pattern-matching-related methods to [FollowUpActionState].
extension FollowUpActionStatePatterns on FollowUpActionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _LoadingHeaders value)?  loadingHeaders,TResult Function( _HeadersLoaded value)?  headersLoaded,TResult Function( _LoadingStudents value)?  loadingStudents,TResult Function( _StudentsLoaded value)?  studentsLoaded,TResult Function( _SendingProgress value)?  sendingProgress,TResult Function( _Success value)?  success,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _LoadingHeaders() when loadingHeaders != null:
return loadingHeaders(_that);case _HeadersLoaded() when headersLoaded != null:
return headersLoaded(_that);case _LoadingStudents() when loadingStudents != null:
return loadingStudents(_that);case _StudentsLoaded() when studentsLoaded != null:
return studentsLoaded(_that);case _SendingProgress() when sendingProgress != null:
return sendingProgress(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _LoadingHeaders value)  loadingHeaders,required TResult Function( _HeadersLoaded value)  headersLoaded,required TResult Function( _LoadingStudents value)  loadingStudents,required TResult Function( _StudentsLoaded value)  studentsLoaded,required TResult Function( _SendingProgress value)  sendingProgress,required TResult Function( _Success value)  success,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _LoadingHeaders():
return loadingHeaders(_that);case _HeadersLoaded():
return headersLoaded(_that);case _LoadingStudents():
return loadingStudents(_that);case _StudentsLoaded():
return studentsLoaded(_that);case _SendingProgress():
return sendingProgress(_that);case _Success():
return success(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _LoadingHeaders value)?  loadingHeaders,TResult? Function( _HeadersLoaded value)?  headersLoaded,TResult? Function( _LoadingStudents value)?  loadingStudents,TResult? Function( _StudentsLoaded value)?  studentsLoaded,TResult? Function( _SendingProgress value)?  sendingProgress,TResult? Function( _Success value)?  success,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _LoadingHeaders() when loadingHeaders != null:
return loadingHeaders(_that);case _HeadersLoaded() when headersLoaded != null:
return headersLoaded(_that);case _LoadingStudents() when loadingStudents != null:
return loadingStudents(_that);case _StudentsLoaded() when studentsLoaded != null:
return studentsLoaded(_that);case _SendingProgress() when sendingProgress != null:
return sendingProgress(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loadingHeaders,TResult Function( List<SheetColumnEntity> assignmentHeaders,  List<SheetColumnEntity> followUpHeaders)?  headersLoaded,TResult Function()?  loadingStudents,TResult Function( List<StudentEntity> missingStudents,  List<StudentEntity> submittedStudents)?  studentsLoaded,TResult Function( int total,  int current,  List<String> failedEmails)?  sendingProgress,TResult Function( String message)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _LoadingHeaders() when loadingHeaders != null:
return loadingHeaders();case _HeadersLoaded() when headersLoaded != null:
return headersLoaded(_that.assignmentHeaders,_that.followUpHeaders);case _LoadingStudents() when loadingStudents != null:
return loadingStudents();case _StudentsLoaded() when studentsLoaded != null:
return studentsLoaded(_that.missingStudents,_that.submittedStudents);case _SendingProgress() when sendingProgress != null:
return sendingProgress(_that.total,_that.current,_that.failedEmails);case _Success() when success != null:
return success(_that.message);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loadingHeaders,required TResult Function( List<SheetColumnEntity> assignmentHeaders,  List<SheetColumnEntity> followUpHeaders)  headersLoaded,required TResult Function()  loadingStudents,required TResult Function( List<StudentEntity> missingStudents,  List<StudentEntity> submittedStudents)  studentsLoaded,required TResult Function( int total,  int current,  List<String> failedEmails)  sendingProgress,required TResult Function( String message)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _LoadingHeaders():
return loadingHeaders();case _HeadersLoaded():
return headersLoaded(_that.assignmentHeaders,_that.followUpHeaders);case _LoadingStudents():
return loadingStudents();case _StudentsLoaded():
return studentsLoaded(_that.missingStudents,_that.submittedStudents);case _SendingProgress():
return sendingProgress(_that.total,_that.current,_that.failedEmails);case _Success():
return success(_that.message);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loadingHeaders,TResult? Function( List<SheetColumnEntity> assignmentHeaders,  List<SheetColumnEntity> followUpHeaders)?  headersLoaded,TResult? Function()?  loadingStudents,TResult? Function( List<StudentEntity> missingStudents,  List<StudentEntity> submittedStudents)?  studentsLoaded,TResult? Function( int total,  int current,  List<String> failedEmails)?  sendingProgress,TResult? Function( String message)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _LoadingHeaders() when loadingHeaders != null:
return loadingHeaders();case _HeadersLoaded() when headersLoaded != null:
return headersLoaded(_that.assignmentHeaders,_that.followUpHeaders);case _LoadingStudents() when loadingStudents != null:
return loadingStudents();case _StudentsLoaded() when studentsLoaded != null:
return studentsLoaded(_that.missingStudents,_that.submittedStudents);case _SendingProgress() when sendingProgress != null:
return sendingProgress(_that.total,_that.current,_that.failedEmails);case _Success() when success != null:
return success(_that.message);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements FollowUpActionState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FollowUpActionState.initial()';
}


}




/// @nodoc


class _LoadingHeaders implements FollowUpActionState {
  const _LoadingHeaders();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadingHeaders);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FollowUpActionState.loadingHeaders()';
}


}




/// @nodoc


class _HeadersLoaded implements FollowUpActionState {
  const _HeadersLoaded({required final  List<SheetColumnEntity> assignmentHeaders, required final  List<SheetColumnEntity> followUpHeaders}): _assignmentHeaders = assignmentHeaders,_followUpHeaders = followUpHeaders;
  

 final  List<SheetColumnEntity> _assignmentHeaders;
 List<SheetColumnEntity> get assignmentHeaders {
  if (_assignmentHeaders is EqualUnmodifiableListView) return _assignmentHeaders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assignmentHeaders);
}

 final  List<SheetColumnEntity> _followUpHeaders;
 List<SheetColumnEntity> get followUpHeaders {
  if (_followUpHeaders is EqualUnmodifiableListView) return _followUpHeaders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_followUpHeaders);
}


/// Create a copy of FollowUpActionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HeadersLoadedCopyWith<_HeadersLoaded> get copyWith => __$HeadersLoadedCopyWithImpl<_HeadersLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HeadersLoaded&&const DeepCollectionEquality().equals(other._assignmentHeaders, _assignmentHeaders)&&const DeepCollectionEquality().equals(other._followUpHeaders, _followUpHeaders));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_assignmentHeaders),const DeepCollectionEquality().hash(_followUpHeaders));

@override
String toString() {
  return 'FollowUpActionState.headersLoaded(assignmentHeaders: $assignmentHeaders, followUpHeaders: $followUpHeaders)';
}


}

/// @nodoc
abstract mixin class _$HeadersLoadedCopyWith<$Res> implements $FollowUpActionStateCopyWith<$Res> {
  factory _$HeadersLoadedCopyWith(_HeadersLoaded value, $Res Function(_HeadersLoaded) _then) = __$HeadersLoadedCopyWithImpl;
@useResult
$Res call({
 List<SheetColumnEntity> assignmentHeaders, List<SheetColumnEntity> followUpHeaders
});




}
/// @nodoc
class __$HeadersLoadedCopyWithImpl<$Res>
    implements _$HeadersLoadedCopyWith<$Res> {
  __$HeadersLoadedCopyWithImpl(this._self, this._then);

  final _HeadersLoaded _self;
  final $Res Function(_HeadersLoaded) _then;

/// Create a copy of FollowUpActionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? assignmentHeaders = null,Object? followUpHeaders = null,}) {
  return _then(_HeadersLoaded(
assignmentHeaders: null == assignmentHeaders ? _self._assignmentHeaders : assignmentHeaders // ignore: cast_nullable_to_non_nullable
as List<SheetColumnEntity>,followUpHeaders: null == followUpHeaders ? _self._followUpHeaders : followUpHeaders // ignore: cast_nullable_to_non_nullable
as List<SheetColumnEntity>,
  ));
}


}

/// @nodoc


class _LoadingStudents implements FollowUpActionState {
  const _LoadingStudents();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadingStudents);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FollowUpActionState.loadingStudents()';
}


}




/// @nodoc


class _StudentsLoaded implements FollowUpActionState {
  const _StudentsLoaded({required final  List<StudentEntity> missingStudents, required final  List<StudentEntity> submittedStudents}): _missingStudents = missingStudents,_submittedStudents = submittedStudents;
  

 final  List<StudentEntity> _missingStudents;
 List<StudentEntity> get missingStudents {
  if (_missingStudents is EqualUnmodifiableListView) return _missingStudents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missingStudents);
}

 final  List<StudentEntity> _submittedStudents;
 List<StudentEntity> get submittedStudents {
  if (_submittedStudents is EqualUnmodifiableListView) return _submittedStudents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_submittedStudents);
}


/// Create a copy of FollowUpActionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudentsLoadedCopyWith<_StudentsLoaded> get copyWith => __$StudentsLoadedCopyWithImpl<_StudentsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudentsLoaded&&const DeepCollectionEquality().equals(other._missingStudents, _missingStudents)&&const DeepCollectionEquality().equals(other._submittedStudents, _submittedStudents));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_missingStudents),const DeepCollectionEquality().hash(_submittedStudents));

@override
String toString() {
  return 'FollowUpActionState.studentsLoaded(missingStudents: $missingStudents, submittedStudents: $submittedStudents)';
}


}

/// @nodoc
abstract mixin class _$StudentsLoadedCopyWith<$Res> implements $FollowUpActionStateCopyWith<$Res> {
  factory _$StudentsLoadedCopyWith(_StudentsLoaded value, $Res Function(_StudentsLoaded) _then) = __$StudentsLoadedCopyWithImpl;
@useResult
$Res call({
 List<StudentEntity> missingStudents, List<StudentEntity> submittedStudents
});




}
/// @nodoc
class __$StudentsLoadedCopyWithImpl<$Res>
    implements _$StudentsLoadedCopyWith<$Res> {
  __$StudentsLoadedCopyWithImpl(this._self, this._then);

  final _StudentsLoaded _self;
  final $Res Function(_StudentsLoaded) _then;

/// Create a copy of FollowUpActionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? missingStudents = null,Object? submittedStudents = null,}) {
  return _then(_StudentsLoaded(
missingStudents: null == missingStudents ? _self._missingStudents : missingStudents // ignore: cast_nullable_to_non_nullable
as List<StudentEntity>,submittedStudents: null == submittedStudents ? _self._submittedStudents : submittedStudents // ignore: cast_nullable_to_non_nullable
as List<StudentEntity>,
  ));
}


}

/// @nodoc


class _SendingProgress implements FollowUpActionState {
  const _SendingProgress({required this.total, required this.current, required final  List<String> failedEmails}): _failedEmails = failedEmails;
  

 final  int total;
 final  int current;
 final  List<String> _failedEmails;
 List<String> get failedEmails {
  if (_failedEmails is EqualUnmodifiableListView) return _failedEmails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_failedEmails);
}


/// Create a copy of FollowUpActionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SendingProgressCopyWith<_SendingProgress> get copyWith => __$SendingProgressCopyWithImpl<_SendingProgress>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendingProgress&&(identical(other.total, total) || other.total == total)&&(identical(other.current, current) || other.current == current)&&const DeepCollectionEquality().equals(other._failedEmails, _failedEmails));
}


@override
int get hashCode => Object.hash(runtimeType,total,current,const DeepCollectionEquality().hash(_failedEmails));

@override
String toString() {
  return 'FollowUpActionState.sendingProgress(total: $total, current: $current, failedEmails: $failedEmails)';
}


}

/// @nodoc
abstract mixin class _$SendingProgressCopyWith<$Res> implements $FollowUpActionStateCopyWith<$Res> {
  factory _$SendingProgressCopyWith(_SendingProgress value, $Res Function(_SendingProgress) _then) = __$SendingProgressCopyWithImpl;
@useResult
$Res call({
 int total, int current, List<String> failedEmails
});




}
/// @nodoc
class __$SendingProgressCopyWithImpl<$Res>
    implements _$SendingProgressCopyWith<$Res> {
  __$SendingProgressCopyWithImpl(this._self, this._then);

  final _SendingProgress _self;
  final $Res Function(_SendingProgress) _then;

/// Create a copy of FollowUpActionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? total = null,Object? current = null,Object? failedEmails = null,}) {
  return _then(_SendingProgress(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,failedEmails: null == failedEmails ? _self._failedEmails : failedEmails // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class _Success implements FollowUpActionState {
  const _Success(this.message);
  

 final  String message;

/// Create a copy of FollowUpActionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuccessCopyWith<_Success> get copyWith => __$SuccessCopyWithImpl<_Success>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'FollowUpActionState.success(message: $message)';
}


}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res> implements $FollowUpActionStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) = __$SuccessCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$SuccessCopyWithImpl<$Res>
    implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

/// Create a copy of FollowUpActionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Success(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Error implements FollowUpActionState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of FollowUpActionState
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
  return 'FollowUpActionState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $FollowUpActionStateCopyWith<$Res> {
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

/// Create a copy of FollowUpActionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
