import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mentor_assistant/core/constants/app_constants.dart';
import 'package:mentor_assistant/features/settings/presentation/pages/cycle_config_page.dart';

class ConfigGroupCard extends StatefulWidget {
  final int index;
  final GroupFormModel form;
  final Function(int) removeGroup;

  const ConfigGroupCard({
    super.key,
    required this.index,
    required this.form,
    required this.removeGroup,
  });

  @override
  State<ConfigGroupCard> createState() => _ConfigGroupCardState();
}

class _ConfigGroupCardState extends State<ConfigGroupCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Row(
          children: [
            Text(
              'Group ${widget.index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (widget.form.nameController.text.isNotEmpty)
              Text(
                ': ${widget.form.nameController.text}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
          onPressed: () => widget.removeGroup,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: widget.form.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    hintText: 'e.g. Friday 10-4 Am',
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
                        value: widget.form.isOnline,
                        onChanged: (val) =>
                            setState(() => widget.form.isOnline = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    if (!widget.form.isOnline) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: widget.form.branchName,
                          decoration: const InputDecoration(
                            labelText: 'Branch',
                          ),
                          items: AppConstants.kBranches
                              .map(
                                (branch) => DropdownMenuItem(
                                  value: branch,
                                  child: Text(branch),
                                ),
                              )
                              .toList(),
                          onChanged: (branch) =>
                              setState(() => widget.form.branchName = branch),
                          validator: (branch) =>
                              !widget.form.isOnline && branch == null
                              ? 'Required to select branch name'
                              : null,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Row Configuration',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assignment Sheet',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: widget.form.startRowController,
                                  decoration: const InputDecoration(
                                    labelText: 'Start',
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller: widget.form.endRowController,
                                  decoration: const InputDecoration(
                                    labelText: 'End',
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Follow-up Sheet',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller:
                                      widget.form.followUpStartRowController,
                                  decoration: const InputDecoration(
                                    labelText: 'Start',
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  controller:
                                      widget.form.followUpEndRowController,
                                  decoration: const InputDecoration(
                                    labelText: 'End',
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(delay: (100 * widget.index).ms);
  }
}
