import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/sheet_column_entity.dart';
import '../cubits/follow_up_action/follow_up_action_cubit.dart';

class FollowUpFilterHeader extends StatefulWidget {
  final Function(int assignmentRow, int followUpRow) onLoadColumns;
  final Function(int assignmentColumnIndex, int statusColumnIndex)
  onFiltersChanged;

  const FollowUpFilterHeader({
    super.key,
    required this.onLoadColumns,
    required this.onFiltersChanged,
  });

  @override
  State<FollowUpFilterHeader> createState() => _FollowUpFilterHeaderState();
}

class _FollowUpFilterHeaderState extends State<FollowUpFilterHeader> {
  final _assignmentRowController = TextEditingController();
  final _followUpRowController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  SheetColumnEntity? _selectedAssignmentColumn;
  SheetColumnEntity? _selectedStatusColumn;

  @override
  void dispose() {
    _assignmentRowController.dispose();
    _followUpRowController.dispose();
    super.dispose();
  }

  void _notifyFiltersChanged() {
    if (_selectedAssignmentColumn != null && _selectedStatusColumn != null) {
      widget.onFiltersChanged(
        _selectedAssignmentColumn!.index,
        _selectedStatusColumn!.index,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration & Filters',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Row 1: Header Row Inputs & Load Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _assignmentRowController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Assignments Sheet Header Row',
                      prefixIcon: Icon(Icons.table_rows_rounded),
                      hintText: 'e.g. 1',
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _followUpRowController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Follow-Up Sheet Header Row',
                      prefixIcon: Icon(Icons.layers_outlined),
                      hintText: 'e.g. 1',
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                BlocBuilder<FollowUpActionCubit, FollowUpActionState>(
                  builder: (context, state) {
                    final isLoading = state.maybeWhen(
                      loadingHeaders: () => true,
                      orElse: () => false,
                    );

                    return SizedBox(
                      height: 56, // Match input height
                      child: ElevatedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  final assignmentRow = int.parse(
                                    _assignmentRowController.text,
                                  );
                                  final followUpRow = int.parse(
                                    _followUpRowController.text,
                                  );
                                  widget.onLoadColumns(
                                    assignmentRow,
                                    followUpRow,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          // Override default infinite width from theme
                          minimumSize: const Size(0, 56),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 20,
                          ),
                        ),
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded),
                        label: Text(
                          isLoading ? 'LOADING...' : 'LOAD COLUMNS',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Row 2: Dropdowns (Animated visibility)
            BlocBuilder<FollowUpActionCubit, FollowUpActionState>(
              builder: (context, state) {
                List<SheetColumnEntity> assignmentHeaders = [];
                List<SheetColumnEntity> followUpHeaders = [];
                bool showDropdowns = false;

                state.maybeWhen(
                  headersLoaded: (assignHeaders, fUpHeaders) {
                    assignmentHeaders = assignHeaders;
                    followUpHeaders = fUpHeaders;
                    showDropdowns = true;
                  },
                  studentsLoaded: (_) {
                    // Logic to keep headers logic visible would require complex state or separate cubit properties.
                    // For now, based on strict request, we just react to headersLoaded.
                    // If user re-enters page, they follow flow.
                  },
                  orElse: () {},
                );

                return AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<SheetColumnEntity>(
                            initialValue: _selectedAssignmentColumn,
                            decoration: const InputDecoration(
                              labelText: 'Select Assignment Column',
                              prefixIcon: Icon(Icons.assignment_outlined),
                            ),
                            items: assignmentHeaders.map((column) {
                              return DropdownMenuItem(
                                value: column,
                                child: Text(
                                  column.headerName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedAssignmentColumn = value;
                              });
                              _notifyFiltersChanged();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<SheetColumnEntity>(
                            initialValue: _selectedStatusColumn,
                            decoration: const InputDecoration(
                              labelText: 'Select Status Column',
                              prefixIcon: Icon(Icons.check_circle_outline),
                            ),
                            items: followUpHeaders.map((column) {
                              return DropdownMenuItem(
                                value: column,
                                child: Text(
                                  column.headerName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatusColumn = value;
                              });
                              _notifyFiltersChanged();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: showDropdowns
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: 300.ms,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
