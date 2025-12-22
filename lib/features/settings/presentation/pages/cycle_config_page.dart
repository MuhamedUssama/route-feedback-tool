import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:mentor_assistant/core/constants/app_constants.dart';
import 'package:mentor_assistant/core/widgets/custom_appbar.dart';
import 'package:mentor_assistant/features/settings/domain/entities/cycle_config_entity.dart';
import 'package:mentor_assistant/features/settings/domain/entities/group_config_entity.dart';
import 'package:mentor_assistant/features/settings/presentation/cubits/cycle_config/cycle_config_cubit.dart';
import 'package:mentor_assistant/features/settings/presentation/cubits/cycle_config/cycle_config_state.dart';

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
        appBar: const CustomAppBar(title: 'Cycle Configuration'),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSectionHeader(
                    context,
                    'General Info',
                    Icons.info_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildGeneralInfoCard(context),

                  const SizedBox(height: 32),
                  _buildSectionHeader(
                    context,
                    'Groups Management',
                    Icons.group_outlined,
                  ),
                  const SizedBox(height: 16),
                  ..._groupForms.asMap().entries.map(
                    (entry) => _buildGroupCard(context, entry.key, entry.value),
                  ),

                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _addGroup,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Group'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveConfig,
                      child: const Text('Save Configuration'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGeneralInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cycleNumberController,
                decoration: const InputDecoration(
                  labelText: 'Cycle Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedTrack,
                decoration: const InputDecoration(
                  labelText: 'Track',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.kTracks
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedTrack = val),
                validator: (value) => value == null ? 'Required' : null,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildGroupCard(BuildContext context, int index, GroupFormModel form) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Row(
          children: [
            Text('Group ${index + 1}'),
            if (form.nameController.text.isNotEmpty)
              Text(
                ': ${form.nameController.text}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          onPressed: () => _removeGroup(index),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: form.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    hintText: 'e.g. Group A',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Is Online?'),
                        value: form.isOnline,
                        onChanged: (val) => setState(() => form.isOnline = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    if (!form.isOnline) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: form.branchName,
                          decoration: const InputDecoration(
                            labelText: 'Branch',
                          ),
                          items: AppConstants.kBranches
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => form.branchName = val),
                          validator: (value) => !form.isOnline && value == null
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: form.startRowController,
                        decoration: const InputDecoration(
                          labelText: 'Start Row',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: form.endRowController,
                        decoration: const InputDecoration(labelText: 'End Row'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(delay: (100 * index).ms);
  }
}

class GroupFormModel {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController startRowController = TextEditingController();
  final TextEditingController endRowController = TextEditingController();
  bool isOnline = true;
  String? branchName;

  GroupFormModel();

  factory GroupFormModel.fromEntity(GroupConfigEntity entity) {
    final model = GroupFormModel();
    model.nameController.text = entity.groupName;
    model.startRowController.text = entity.assignmentStartRow.toString();
    model.endRowController.text = entity.assignmentEndRow.toString();
    model.isOnline = entity.isOnline;
    model.branchName = entity.branchName;
    return model;
  }

  void dispose() {
    nameController.dispose();
    startRowController.dispose();
    endRowController.dispose();
  }

  GroupConfigEntity toEntity() {
    return GroupConfigEntity(
      groupName: nameController.text,
      isOnline: isOnline,
      branchName: isOnline ? null : branchName,
      assignmentStartRow: int.parse(startRowController.text),
      assignmentEndRow: int.parse(endRowController.text),
    );
  }
}
