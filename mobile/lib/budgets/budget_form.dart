import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_error.dart';
import 'budgets_controller.dart';

const _types = {
  BudgetRequestTypeEnum.envelope: 'Envelope',
  BudgetRequestTypeEnum.goal: 'Goal',
  BudgetRequestTypeEnum.tracking: 'Track spending only',
};

/// Editing one budget. `balance` is what the user wants allocated; the server diffs it into an
/// adjustment and answers with the recalculated figure, so nothing here is worked out locally.
class BudgetForm extends ConsumerStatefulWidget {
  const BudgetForm({super.key, this.budget});

  final Budget? budget;

  @override
  ConsumerState<BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends ConsumerState<BudgetForm> {
  late final _name = TextEditingController(text: widget.budget?.name ?? '');
  late final _budgetedAmount = TextEditingController(text: widget.budget?.budgetedAmount ?? '');
  late final _balance = TextEditingController(text: widget.budget?.balance ?? '');

  late var _type = switch (widget.budget?.type) {
    BudgetTypeEnum.goal => BudgetRequestTypeEnum.goal,
    BudgetTypeEnum.tracking => BudgetRequestTypeEnum.tracking,
    _ => BudgetRequestTypeEnum.envelope,
  };

  @override
  void dispose() {
    _name.dispose();
    _budgetedAmount.dispose();
    _balance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetsControllerProvider);
    final errors = state.error is ApiError
        ? (state.error! as ApiError).fieldErrors
        : const <String, String>{};
    final tracking = _type == BudgetRequestTypeEnum.tracking;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.budget == null ? 'New budget' : 'Edit budget',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('budget-name'),
            controller: _name,
            decoration: InputDecoration(labelText: 'Name', errorText: errors['/name']),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField(
            key: const Key('budget-type'),
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Budget type'),
            items: [
              for (final entry in _types.entries)
                DropdownMenuItem(value: entry.key, child: Text(entry.value)),
            ],
            onChanged: (value) => setState(() => _type = value ?? _type),
          ),
          if (!tracking) ...[
            const SizedBox(height: 16),
            TextField(
              key: const Key('budget-amount'),
              controller: _budgetedAmount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _type == BudgetRequestTypeEnum.goal ? 'Goal amount' : 'Budgeted amount',
                errorText: errors['/budgeted_amount'],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('budget-balance'),
              controller: _balance,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: InputDecoration(labelText: 'Allocated', errorText: errors['/balance']),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('budget-save'),
            onPressed: state.isLoading ? null : _save,
            child: const Text('Save'),
          ),
          if (widget.budget case final budget?) ...[
            const SizedBox(height: 8),
            TextButton(
              key: const Key('budget-archive'),
              onPressed: state.isLoading ? null : () => _archive(budget.id),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Archive budget'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    final tracking = _type == BudgetRequestTypeEnum.tracking;

    final request = BudgetRequest(
      (builder) => builder
        ..name = _name.text
        ..type = _type
        ..budgetedAmount = tracking ? null : _blankToNull(_budgetedAmount.text)
        ..balance = tracking ? null : _blankToNull(_balance.text),
    );

    await _close(ref.read(budgetsControllerProvider.notifier).save(id: widget.budget?.id, request: request));
  }

  Future<void> _archive(String id) => _close(ref.read(budgetsControllerProvider.notifier).archive(id));

  /// A failure keeps the sheet open so the field errors have somewhere to land.
  Future<void> _close(Future<bool> write) async {
    final saved = await write;

    if (saved && mounted) Navigator.of(context).pop();
  }

  String? _blankToNull(String value) => value.trim().isEmpty ? null : value.trim();
}
