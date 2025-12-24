import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/features/auth/domain/repositories/auth_repository.dart';
import 'package:mentor_assistant/features/follow_up/domain/repositories/follow_up_repository.dart';
import 'package:mentor_assistant/features/report/domain/repositories/report_repository.dart';
import 'package:mentor_assistant/features/settings/domain/entities/group_config_entity.dart';
import 'package:mentor_assistant/features/settings/domain/repositories/cycle_repository.dart';
import 'report_state.dart';

@injectable
class ReportCubit extends Cubit<ReportState> {
  final CycleRepository _cycleRepository;
  final ReportRepository _reportRepository;
  final FollowUpRepository _followUpRepository;
  final AuthRepository _authRepository;

  ReportCubit(
    this._cycleRepository,
    this._reportRepository,
    this._followUpRepository,
    this._authRepository,
  ) : super(const ReportState.initial());

  Future<void> init() async {
    emit(const ReportState.loading());
    try {
      final configResult = await _cycleRepository.getConfig();
      final config = configResult.fold((_) => null, (config) => config);

      if (config == null || config.groups.isEmpty) {
        emit(const ReportState.noConfig());
        return;
      }

      final userResult = await _authRepository.getCachedUser();
      final user = userResult.fold((_) => null, (user) => user);

      emit(ReportState.ready(config: config, groupStats: {}, user: user!));
    } catch (e) {
      emit(ReportState.error(e.toString()));
    }
  }

  Future<void> calculateStatsForGroup(
    GroupConfigEntity group,
    String assignmentCol,
    String followUpCol,
  ) async {
    // Capture current state safely
    final currentState = state.mapOrNull(ready: (s) => s);
    if (currentState == null) return;

    // Add group to loading set
    final updatedLoading = Set<String>.from(currentState.loadingGroupNames)
      ..add(group.groupName);

    emit(
      currentState.copyWith(
        loadingGroupNames: updatedLoading,
        errorMessage: null,
      ),
    );

    // 1. Get URLs
    final configResult = await _followUpRepository.getFollowUpConfig();

    await configResult.fold(
      (failure) async {
        final resetLoading = Set<String>.from(currentState.loadingGroupNames)
          ..remove(group.groupName);
        emit(
          currentState.copyWith(
            loadingGroupNames: resetLoading,
            errorMessage: failure.message,
          ),
        );
      },
      (config) async {
        if (config == null ||
            config.assignmentsSheetUrl.isEmpty ||
            config.followUpSheetUrl.isEmpty) {
          final resetLoading = Set<String>.from(currentState.loadingGroupNames)
            ..remove(group.groupName);
          emit(
            currentState.copyWith(
              loadingGroupNames: resetLoading,
              errorMessage: "Please configure Sheet URLs in Settings first.",
            ),
          );
          return;
        }

        // 2. Calculate Stats
        final statsResult = await _reportRepository.calculateGroupStats(
          group: group,
          assignmentSheetUrl: config.assignmentsSheetUrl,
          followUpSheetUrl: config.followUpSheetUrl,
          assignmentColumn: assignmentCol,
          followUpColumn: followUpCol,
          assignmentEmailAnchorColumn:
              currentState.config?.assignmentEmailColumn ?? '',
          followUpEmailAnchorColumn:
              currentState.config?.followUpEmailColumn ?? '',
        );

        statsResult.fold(
          (failure) {
            final resetLoading = Set<String>.from(
              currentState.loadingGroupNames,
            )..remove(group.groupName);
            emit(
              currentState.copyWith(
                loadingGroupNames: resetLoading,
                errorMessage: failure.message,
              ),
            );
          },
          (stats) {
            final newStats = Map<String, Map<String, int>>.from(
              currentState.groupStats,
            );
            newStats[group.groupName] = stats;

            final resetLoading = Set<String>.from(
              currentState.loadingGroupNames,
            )..remove(group.groupName);

            emit(
              currentState.copyWith(
                groupStats: newStats,
                loadingGroupNames: resetLoading,
                errorMessage: null,
              ),
            );
          },
        );
      },
    );
  }
}
