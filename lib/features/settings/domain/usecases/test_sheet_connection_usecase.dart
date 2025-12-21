import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/core/errors/failures.dart';
import 'package:mentor_assistant/core/usecases/usecase.dart';
import 'package:mentor_assistant/core/utils/google_sheet_url_parser.dart';
import 'package:mentor_assistant/features/follow_up/domain/repositories/follow_up_repository.dart';

@lazySingleton
class TestSheetConnectionUseCase
    implements UseCase<bool, TestSheetConnectionParams> {
  final FollowUpRepository _repository;

  TestSheetConnectionUseCase(this._repository);

  @override
  Future<Either<Failure, bool>> call(TestSheetConnectionParams params) async {
    final info = GoogleSheetUrlParser.parse(params.url);
    if (info == null) {
      return Left(Failure.sheet("Invalid URL format"));
    }

    // Try to fetch headers for the first row to validate access
    final result = await _repository.getSheetHeaders(
      info.spreadsheetId,
      info.gid,
      1, // Header row index 1
      detectMergedHeaders: false,
    );

    return result.fold((failure) => Left(failure), (_) => const Right(true));
  }
}

class TestSheetConnectionParams extends Equatable {
  final String url;

  const TestSheetConnectionParams({required this.url});

  @override
  List<Object?> get props => [url];
}
