import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentor_assistant/features/report/presentation/cubits/report_cubit.dart';
import 'package:mentor_assistant/features/report/presentation/widgets/group_report_card.dart';
import 'package:mentor_assistant/features/report/presentation/widgets/logistics_card.dart';
import 'package:mentor_assistant/features/report/presentation/widgets/workshop_card.dart';
import 'package:mentor_assistant/features/settings/data/models/group_config_model.dart';
import 'package:mentor_assistant/features/settings/presentation/widgets/config_section_header.dart';

class ReportFormWidget extends StatelessWidget {
  final List<GroupConfigModel> groups;
  final Map<String, Map<String, int>> stats;
  final List<String> loadingGroupNames;

  const ReportFormWidget({
    super.key,
    required this.groups,
    required this.stats,
    required this.loadingGroupNames,
  });

  @override
  Widget build(BuildContext context) {
    final offlineGroups = groups.where((g) => !g.isOnline).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Groups Data
              const ConfigSectionHeader(
                title: 'Groups Data',
                icon: Icons.group,
              ),
              const SizedBox(height: 16),
              ...groups.map(
                (group) => GroupReportCard(
                  group: group,
                  stats: stats[group.groupName],
                  isCalculating: loadingGroupNames.contains(group.groupName),
                  onCalculateStats: (assignCol, followUpCol) {
                    context.read<ReportCubit>().calculateStatsForGroup(
                      group,
                      assignCol,
                      followUpCol,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // 2. Workshop Info
              const ConfigSectionHeader(
                title: 'Workshop Info',
                icon: Icons.lightbulb,
              ),
              const SizedBox(height: 16),
              const WorkshopCard(),
              const SizedBox(height: 24),
              // 3. Logistics
              if (offlineGroups.isNotEmpty) ...[
                const ConfigSectionHeader(
                  title: 'Logistics',
                  icon: Icons.location_city_rounded,
                ),
                const SizedBox(height: 16),

                ...offlineGroups.map((group) => LogisticsCard(group: group)),
              ],

              // const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
