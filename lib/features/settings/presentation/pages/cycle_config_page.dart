import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mentor_assistant/core/widgets/custom_appbar.dart';
import 'package:mentor_assistant/features/settings/domain/entities/cycle_config_entity.dart';
import 'package:mentor_assistant/features/settings/domain/entities/group_config_entity.dart';
import 'package:mentor_assistant/features/settings/presentation/cubits/cycle_config/cycle_config_cubit.dart';
import 'package:mentor_assistant/features/settings/presentation/cubits/cycle_config/cycle_config_state.dart';
import 'package:mentor_assistant/features/settings/presentation/widgets/config_general_info_card.dart';
import 'package:mentor_assistant/features/settings/presentation/widgets/config_group_card.dart';
import 'package:mentor_assistant/features/settings/presentation/widgets/config_section_header.dart';

class CycleConfigPage extends StatelessWidget {
  const CycleConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<CycleConfigCubit>()..loadConfig(),
      child: const _CycleConfigView(),
    );
  }
}

class _CycleConfigView extends StatefulWidget {
  const _CycleConfigView();

  @override
  State<_CycleConfigView> createState() => _CycleConfigViewState();
}

class _CycleConfigViewState extends State<_CycleConfigView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for general info
  final _cycleNumberController = TextEditingController();
  String? _selectedTrack;

  // List of group data
  // Using a local DTO or simple map to manage state before saving
  List<GroupFormModel> _groupForms = [];

  @override
  void dispose() {
    _cycleNumberController.dispose();
    for (var group in _groupForms) {
      group.dispose();
    }
    super.dispose();
  }

  void _loadConfig(CycleConfigEntity? config) {
    if (config != null) {
      _cycleNumberController.text = config.cycleNumber.toString();
      _selectedTrack = config.trackName;

      setState(() {
        _groupForms = config.groups
            .map((e) => GroupFormModel.fromEntity(e))
            .toList();
      });
    }
  }

  void _addGroup() {
    setState(() {
      _groupForms.add(GroupFormModel());
    });
  }

  void _removeGroup(int index) {
    setState(() {
      _groupForms.removeAt(index);
    });
  }

  void _saveConfig() {
    if (_formKey.currentState!.validate()) {
      final groups = _groupForms.map((e) => e.toEntity()).toList();
      final config = CycleConfigEntity(
        cycleNumber: int.parse(_cycleNumberController.text),
        trackName: _selectedTrack!,
        groups: groups,
      );
      context.read<CycleConfigCubit>().saveConfig(config);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CycleConfigCubit, CycleConfigState>(
      listener: (context, state) {
        state.maybeWhen(
          loaded: (config) => _loadConfig(config),
          success: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Configuration saved successfully!'),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
              ),
            );
          },
          error: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        appBar: const CustomAppBar(
          withBackButton: true,
          title: 'Cycle Configuration',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    ConfigSectionHeader(
                      title: 'General Info',
                      icon: Icons.info_outline,
                    ),
                    const SizedBox(height: 16),
                    ConfigGeneralInfoCard(
                      cycleNumberController: _cycleNumberController,
                      selectedTrack: _selectedTrack,
                      onTrackChanged: (val) {
                        setState(() {
                          _selectedTrack = val;
                        });
                      },
                    ),

                    const SizedBox(height: 32),
                    ConfigSectionHeader(
                      title: 'Groups Management',
                      icon: Icons.group_outlined,
                    ),
                    const SizedBox(height: 16),
                    ..._groupForms.asMap().entries.map(
                      (entry) => ConfigGroupCard(
                        index: entry.key,
                        form: entry.value,
                        removeGroup: (index) => _removeGroup(index),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                          onPressed: _addGroup,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Group'),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: 400.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutQuad,
                        ),
                    const SizedBox(height: 48),
                    SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveConfig,
                            child: const Text('Save Configuration'),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: 600.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutQuad,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GroupFormModel {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController startRowController = TextEditingController();
  final TextEditingController endRowController = TextEditingController();
  final TextEditingController followUpStartRowController =
      TextEditingController();
  final TextEditingController followUpEndRowController =
      TextEditingController();
  bool isOnline = true;
  String? branchName;

  GroupFormModel();

  factory GroupFormModel.fromEntity(GroupConfigEntity entity) {
    final model = GroupFormModel();
    model.nameController.text = entity.groupName;
    model.startRowController.text = entity.assignmentStartRow.toString();
    model.endRowController.text = entity.assignmentEndRow.toString();
    model.followUpStartRowController.text = entity.followUpStartRow.toString();
    model.followUpEndRowController.text = entity.followUpEndRow.toString();
    model.isOnline = entity.isOnline;
    model.branchName = entity.branchName;
    return model;
  }

  void dispose() {
    nameController.dispose();
    startRowController.dispose();
    endRowController.dispose();
    followUpStartRowController.dispose();
    followUpEndRowController.dispose();
  }

  GroupConfigEntity toEntity() {
    return GroupConfigEntity(
      groupName: nameController.text,
      isOnline: isOnline,
      branchName: isOnline ? null : branchName,
      assignmentStartRow: int.parse(startRowController.text),
      assignmentEndRow: int.parse(endRowController.text),
      followUpStartRow: int.parse(followUpStartRowController.text),
      followUpEndRow: int.parse(followUpEndRowController.text),
    );
  }
}
