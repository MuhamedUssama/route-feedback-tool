import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/features/follow_up/domain/repositories/follow_up_repository.dart';
import 'package:mentor_assistant/features/report/domain/repositories/report_repository.dart';
import 'package:mentor_assistant/features/settings/data/datasources/cycle_local_data_source.dart';
import 'package:mentor_assistant/features/settings/data/models/group_config_model.dart';
import 'report_state.dart';

@injectable
class ReportCubit extends Cubit<ReportState> {
  final CycleLocalDataSource _cycleLocalDataSource;
  final ReportRepository _reportRepository;
  final FollowUpRepository _followUpRepository;

  ReportCubit(
    this._cycleLocalDataSource,
    this._reportRepository,
    this._followUpRepository,
  ) : super(const ReportState.initial());

  Future<void> init() async {
    emit(const ReportState.loading());
    try {
      final config = await _cycleLocalDataSource.getConfig();
      if (config == null || config.groups.isEmpty) {
        emit(const ReportState.noConfig());
        return;
      }

      emit(ReportState.ready(groups: config.groups, groupStats: {}));
    } catch (e) {
      emit(ReportState.error(e.toString()));
    }
  }

  Future<void> calculateStatsForGroup(
    GroupConfigModel group,
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
