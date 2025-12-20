import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/core/usecases/usecase.dart';
import '../../../domain/entities/follow_up_config_entity.dart';
import '../../../domain/usecases/get_follow_up_config_usecase.dart';
import '../../../domain/usecases/save_follow_up_config_usecase.dart';

part 'follow_up_config_state.dart';
part 'follow_up_config_cubit.freezed.dart';

@injectable
class FollowUpConfigCubit extends Cubit<FollowUpConfigState> {
  final GetFollowUpConfigUseCase _getFollowUpConfigUseCase;
  final SaveFollowUpConfigUseCase _saveFollowUpConfigUseCase;

  FollowUpConfigCubit(
    this._getFollowUpConfigUseCase,
    this._saveFollowUpConfigUseCase,
  ) : super(const FollowUpConfigState.initial());

  Future<void> checkConfig() async {
    emit(const FollowUpConfigState.loading());
    final result = await _getFollowUpConfigUseCase(const NoParams());
    result.fold((failure) => emit(FollowUpConfigState.error(failure.message)), (
      config,
    ) {
      if (config == null) {
        emit(const FollowUpConfigState.configMissing());
      } else {
        emit(FollowUpConfigState.configLoaded(config));
      }
    });
  }

  Future<void> saveConfig({
    required String assignmentsSheetId,
    required String followUpSheetId,
  }) async {
    emit(const FollowUpConfigState.loading());

    final config = FollowUpConfigEntity(
      assignmentsSheetId: assignmentsSheetId,
      followUpSheetId: followUpSheetId,
    );

    final result = await _saveFollowUpConfigUseCase(
      SaveFollowUpConfigParams(config),
    );

    result.fold(
      (failure) => emit(FollowUpConfigState.error(failure.message)),
      (_) => emit(FollowUpConfigState.configLoaded(config)),
    );
  }
}
