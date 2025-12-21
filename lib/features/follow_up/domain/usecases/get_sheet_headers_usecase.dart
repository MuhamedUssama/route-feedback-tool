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
  ) {
    return _repository.getSheetHeaders(
      params.spreadsheetId,
      params.sheetId,
      params.headerRowIndex,
      detectMergedHeaders: params.detectMergedHeaders,
    );
  }
}

class GetSheetHeadersParams extends Equatable {
  final String spreadsheetId;
  final int? sheetId;
  final int headerRowIndex;
  final bool detectMergedHeaders;

  const GetSheetHeadersParams({
    required this.spreadsheetId,
    required this.sheetId,
    required this.headerRowIndex,
    this.detectMergedHeaders = false,
  });

  @override
  List<Object?> get props => [
    spreadsheetId,
    sheetId,
    headerRowIndex,
    detectMergedHeaders,
  ];
}
