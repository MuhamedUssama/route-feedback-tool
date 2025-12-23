import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:mentor_assistant/features/report/presentation/cubits/report_cubit.dart';
import 'package:mentor_assistant/features/report/presentation/cubits/report_state.dart';
import 'package:mentor_assistant/features/settings/presentation/widgets/config_section_header.dart';
import 'package:mentor_assistant/features/main_layout/cubit/navigation_cubit.dart'; // Added
import 'package:mentor_assistant/features/settings/data/models/group_config_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mentor_assistant/core/widgets/custom_appbar.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<ReportCubit>(),
      child: const _ReportScreenView(),
    );
  }
}

class _ReportScreenView extends StatefulWidget {
  const _ReportScreenView();

  @override
  State<_ReportScreenView> createState() => _ReportScreenViewState();
}

class _ReportScreenViewState extends State<_ReportScreenView> {
  // Config & Automation Controllers
  final Map<String, Map<String, TextEditingController>> _columnControllers = {};
  // Track Feedback Button State
  final Map<String, bool> _feedbackDone = {};

  // Assignment Info Controllers (Ephemeral for the report)
  final Map<String, TextEditingController> _assignmentNameControllers = {};
  final Map<String, TextEditingController> _assignmentNumberControllers = {};
  final Map<String, DateTime?> _deadlines = {};

  // Workshop Controllers
  final _topicController = TextEditingController();
  DateTime _workshopDate = DateTime.now();

  // Logistics Controllers
  final Map<String, bool> _visits = {};
  final Map<String, TextEditingController> _exceptionControllers = {};
  final Map<String, TimeOfDay?> _arrivalTimes = {};
  final Map<String, TimeOfDay?> _departureTimes = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportCubit>().init();
    });
  }

  @override
  void dispose() {
    for (var map in _columnControllers.values) {
      for (var ctrl in map.values) {
        ctrl.dispose();
      }
    }
    for (var ctrl in _assignmentNameControllers.values) {
      ctrl.dispose();
    }
    for (var ctrl in _assignmentNumberControllers.values) {
      ctrl.dispose();
    }

    _topicController.dispose();
    for (var ctrl in _exceptionControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Weekly Report', withBackButton: false),
      body: BlocConsumer<ReportCubit, ReportState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (msg) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg), backgroundColor: Colors.red),
              );
            },
            ready: (_, __, ___, errorMessage) {
              if (errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const Center(child: CircularProgressIndicator()),
            noConfig: () => _buildNoConfigState(context),
            ready: (config, stats, loadingGroupNames, _) => _buildReportForm(
              context,
              config.groups,
              stats,
              loadingGroupNames,
            ),
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _generatePdf(context),
        label: const Text('Generate PDF'),
        icon: const Icon(Icons.picture_as_pdf),
      ),
    );
  }

  void _generatePdf(BuildContext context) {
    // Collect Data and Print to Console for Verification Phase
    print('--- Generating PDF Report ---');
    print('Workshop: ${_topicController.text} on $_workshopDate');

    // Groups Data
    for (var entry in _assignmentNameControllers.entries) {
      final grp = entry.key;
      print('Group: $grp');
      print('  Assign No: ${_assignmentNumberControllers[grp]?.text}');
      print('  Assign Name: ${_assignmentNameControllers[grp]?.text}');
      print('  Deadline: ${_deadlines[grp]}');
      // Stats from Cubit
      // Safe to assume we have access if needed
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report Data Logged to Console (PDF Pending)'),
      ),
    );
  }

  Widget _buildNoConfigState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings_suggest, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Cycle not configured yet.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Please go to Settings to configure your groups.'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to Settings (Index 3)
              context.read<NavigationCubit>().changeIndex(3);
            },
            child: const Text('Go to Settings'),
          ).animate().fadeIn(),
        ],
      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildReportForm(
    BuildContext context,
    List<GroupConfigModel> groups,
    Map<String, Map<String, int>> stats,
    Set<String> loadingGroupNames,
  ) {
    // Offline groups for Logistics
    final offlineGroups = groups.where((g) => !g.isOnline).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Groups Data
          const ConfigSectionHeader(title: 'Groups Data', icon: Icons.group),
          ...groups.map(
            (group) => _buildGroupCard(
              context,
              group,
              stats,
              loadingGroupNames.contains(group.groupName),
            ),
          ),

          const SizedBox(height: 24),

          // 2. Workshop Info
          const ConfigSectionHeader(
            title: 'Workshop Info',
            icon: Icons.lightbulb,
          ),
          _buildWorkshopCard(context),

          const SizedBox(height: 24),

          // 3. Logistics
          if (offlineGroups.isNotEmpty) ...[
            const ConfigSectionHeader(
              title: 'Logistics',
              icon: Icons.directions_car,
            ),
            ...offlineGroups.map(
              (group) => _buildLogisticsCard(context, group),
            ),
          ],

          const SizedBox(height: 80), // Fab space
        ],
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    GroupConfigModel group,
    Map<String, Map<String, int>> stats,
    bool isCalculating,
  ) {
    final gName = group.groupName;

    // Initialize controllers
    if (!_columnControllers.containsKey(gName)) {
      _columnControllers[gName] = {
        'assignment': TextEditingController(),
        'followUp': TextEditingController(),
      };
      _assignmentNameControllers[gName] = TextEditingController();
      _assignmentNumberControllers[gName] = TextEditingController();
    }

    final groupStats = stats[gName];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    gName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text('Feedback Done?'),
                Switch(
                  value: _feedbackDone[gName] ?? false,
                  onChanged: (val) {
                    setState(() {
                      _feedbackDone[gName] = val;
                      // Logic for when feedback is marked done
                      if (val) {
                        // Optionally trigger something or just track state
                      }
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Assignment Details Inputs
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _assignmentNumberControllers[gName],
                    decoration: const InputDecoration(
                      labelText: 'Assign No',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _deadlines[gName] ?? now,
                        firstDate: now.subtract(const Duration(days: 30)),
                        lastDate: now.add(const Duration(days: 60)),
                      );
                      if (date != null) {
                        setState(() => _deadlines[gName] = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Deadline',
                        isDense: true,
                        suffixIcon: Icon(Icons.calendar_today, size: 16),
                      ),
                      child: Text(
                        _deadlines[gName] != null
                            ? DateFormat('MM/dd').format(_deadlines[gName]!)
                            : 'Select',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _assignmentNameControllers[gName],
              decoration: const InputDecoration(
                labelText: 'Assignment Name',
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),

            // Automation Inputs
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _columnControllers[gName]!['assignment'],
                    decoration: const InputDecoration(
                      labelText: 'Assign Col (e.g. H)',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _columnControllers[gName]!['followUp'],
                    decoration: const InputDecoration(
                      labelText: 'F.Up Col (e.g. K)',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: isCalculating
                      ? null
                      : () {
                          final assignCol =
                              _columnControllers[gName]!['assignment']!.text;
                          final fupCol =
                              _columnControllers[gName]!['followUp']!.text;

                          if (assignCol.isEmpty || fupCol.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter both columns'),
                              ),
                            );
                            return;
                          }

                          context.read<ReportCubit>().calculateStatsForGroup(
                            group,
                            assignCol,
                            fupCol,
                          );
                        },
                  icon: isCalculating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.analytics),
                  tooltip: 'Calculate Stats',
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Stats Display
            if (groupStats != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatChip(
                    'Submitted',
                    groupStats['submitted']!,
                    Colors.green,
                  ),
                  _buildStatChip(
                    'Missing',
                    groupStats['unsubmitted']!,
                    Colors.orange,
                  ),
                  _buildStatChip(
                    'Followed Up',
                    groupStats['followUp']!,
                    Colors.blue,
                  ),
                ],
              ).animate().fadeIn(),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0, delay: 100.ms);
  }

  Widget _buildStatChip(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildWorkshopCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(labelText: 'Workshop Topic'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _workshopDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _workshopDate = date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('yyyy-MM-dd').format(_workshopDate)),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0, delay: 200.ms);
  }

  Widget _buildLogisticsCard(BuildContext context, GroupConfigModel group) {
    if (!_visits.containsKey(group.groupName)) {
      _visits[group.groupName] = true;
      _exceptionControllers[group.groupName] = TextEditingController();
    }

    final isVisited = _visits[group.groupName]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${group.branchName ?? "Unknown Branch"} - ${group.groupName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: isVisited,
                  onChanged: (val) {
                    setState(() => _visits[group.groupName] = val!);
                  },
                ),
                const Text('Visited this week?'),
              ],
            ),
            if (isVisited)
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(
                      context,
                      'Arrival',
                      _arrivalTimes[group.groupName],
                      (t) => setState(() => _arrivalTimes[group.groupName] = t),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimePicker(
                      context,
                      'Departure',
                      _departureTimes[group.groupName],
                      (t) =>
                          setState(() => _departureTimes[group.groupName] = t),
                    ),
                  ),
                ],
              )
            else
              TextField(
                controller: _exceptionControllers[group.groupName],
                decoration: const InputDecoration(
                  labelText: 'Exception Reason',
                ),
              ).animate().fadeIn(),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0, delay: 300.ms);
  }

  Widget _buildTimePicker(
    BuildContext context,
    String label,
    TimeOfDay? time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (t != null) onChanged(t);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(time?.format(context) ?? 'Select'),
      ),
    );
  }
}
