import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/sheet_column_entity.dart';
import '../../presentation/cubits/follow_up_action/follow_up_action_cubit.dart';

class FollowUpFilterHeader extends StatefulWidget {
  final Function(int masterRow, int localRow) onLoadColumns;
  final Function(int assignmentColIndex, int statusColIndex) onColumnsSelected;

  const FollowUpFilterHeader({
    super.key,
    required this.onLoadColumns,
    required this.onColumnsSelected,
  });

  @override
  State<FollowUpFilterHeader> createState() => _FollowUpFilterHeaderState();
}

class _FollowUpFilterHeaderState extends State<FollowUpFilterHeader> {
  final _masterRowController = TextEditingController();
  final _localRowController = TextEditingController();

  SheetColumnEntity? _selectedAssignmentCol;
  SheetColumnEntity? _selectedStatusCol;

  @override
  void dispose() {
    _masterRowController.dispose();
    _localRowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerTheme.color ?? Colors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BlocBuilder<FollowUpActionCubit, FollowUpActionState>(
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loadingHeaders: () => true,
            orElse: () => false,
          );

          final headers = state.maybeWhen(
            headersLoaded: (h) => h,
            orElse: () => <SheetColumnEntity>[],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Config
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildNumberInput(
                    context,
                    controller: _masterRowController,
                    label: 'Master Header Row',
                    hint: '1',
                  ),
                  const SizedBox(width: 16),
                  _buildNumberInput(
                    context,
                    controller: _localRowController,
                    label: 'Local Header Row',
                    hint: '1',
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final mRow = int.tryParse(
                              _masterRowController.text,
                            );
                            final lRow = int.tryParse(_localRowController.text);
                            if (mRow != null && lRow != null) {
                              widget.onLoadColumns(mRow, lRow);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('LOAD COLUMNS'),
                  ),
                ],
              ),

              // Row 2: Selectors (Animate In)
              if (headers.isNotEmpty || _selectedAssignmentCol != null) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        context,
                        label: 'Select Assignment Column',
                        items: headers,
                        value: _selectedAssignmentCol,
                        onChanged: (val) {
                          setState(() => _selectedAssignmentCol = val);
                          _notifyIfReady();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        context,
                        label: 'Select Status Column',
                        items: headers,
                        value: _selectedStatusCol,
                        onChanged: (val) {
                          setState(() => _selectedStatusCol = val);
                          _notifyIfReady();
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: -0.1, end: 0),
              ],
            ],
          );
        },
      ),
    );
  }

  void _notifyIfReady() {
    if (_selectedAssignmentCol != null && _selectedStatusCol != null) {
      widget.onColumnsSelected(
        _selectedAssignmentCol!.index,
        _selectedStatusCol!.index,
      );
    }
  }

  Widget _buildNumberInput(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String label,
    required List<SheetColumnEntity> items,
    required SheetColumnEntity? value,
    required ValueChanged<SheetColumnEntity?> onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<SheetColumnEntity>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item.headerName,
                style: GoogleFonts.inter(),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
