import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/follow_up_repository.dart';

@lazySingleton
class CheckStudentRepliesUseCase
    implements UseCase<void, CheckStudentRepliesParams> {
  final FollowUpRepository _repository;

  CheckStudentRepliesUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(CheckStudentRepliesParams params) async {
    return await _repository.checkStudentReplies(
      spreadsheetId: params.spreadsheetId,
      sheetId: params.sheetId,
      statusColumnIndex: params.statusColumnIndex,
      followUpHeaderRowIndex: params.followUpHeaderRowIndex,
    );
  }
}

class CheckStudentRepliesParams extends Equatable {
  final String spreadsheetId;
  final int? sheetId;
  final int statusColumnIndex;
  final int followUpHeaderRowIndex;

  const CheckStudentRepliesParams({
    required this.spreadsheetId,
    required this.sheetId,
    required this.statusColumnIndex,
    required this.followUpHeaderRowIndex,
  });

  @override
  List<Object?> get props => [
    spreadsheetId,
    sheetId,
    statusColumnIndex,
    followUpHeaderRowIndex,
  ];
}
