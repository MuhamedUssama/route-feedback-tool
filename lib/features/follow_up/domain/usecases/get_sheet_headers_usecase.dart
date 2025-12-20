import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sheet_column_entity.dart';
import '../repositories/follow_up_repository.dart';

@lazySingleton
class GetSheetHeadersUseCase
    implements UseCase<List<SheetColumnEntity>, GetSheetHeadersParams> {
  final FollowUpRepository _repository;

  GetSheetHeadersUseCase(this._repository);

  @override
  Future<Either<Failure, List<SheetColumnEntity>>> call(
    GetSheetHeadersParams params,
  ) async {
    return await _repository.getSheetHeaders(
      params.spreadsheetId,
      params.sheetIndex,
      params.headerRowIndex,
    );
  }
}

class GetSheetHeadersParams extends Equatable {
  final String spreadsheetId;
  final int sheetIndex;
  final int headerRowIndex;

  const GetSheetHeadersParams({
    required this.spreadsheetId,
    required this.sheetIndex,
    required this.headerRowIndex,
  });

  @override
  List<Object?> get props => [spreadsheetId, sheetIndex, headerRowIndex];
}
