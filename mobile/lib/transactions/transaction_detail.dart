import 'package:built_collection/built_collection.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart' hide Split;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_error.dart';
import '../theme.dart';
import 'transactions_controller.dart';
import 'transactions_providers.dart';

/// One allocation being edited. Kept apart from the wire type because a line the user is still
/// typing has no valid amount yet.
class _Line {
  _Line({this.id, required this.budgetId, required String amount})
    : amount = TextEditingController(text: amount);

  final String? id;
  final TextEditingController amount;

  String? budgetId;
}

class TransactionDetail extends ConsumerStatefulWidget {
  const TransactionDetail({super.key, required this.transaction});

  final Transaction transaction;

  @override
  ConsumerState<TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends ConsumerState<TransactionDetail> {
  late final _name = TextEditingController(text: widget.transaction.name);
  late final _amount = TextEditingController(text: widget.transaction.amount);
  late final _note = TextEditingController(text: widget.transaction.note ?? '');

  late var _date = widget.transaction.date;
  late var _reviewed = widget.transaction.reviewed;
  late var _excluded = widget.transaction.excluded;

  late var _lines = [
    for (final allocation in widget.transaction.budgetAllocations)
      _Line(id: allocation.id, budgetId: allocation.budgetId, amount: allocation.amount),
  ];

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _note.dispose();
    for (final line in _lines) {
      line.amount.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsControllerProvider);
    final errors = state.error is ApiError
        ? (state.error! as ApiError).fieldErrors
        : const <String, String>{};
    final budgets = ref.watch(budgetOptionsProvider).value ?? const <Budget>[];

    // Watched rather than read in the picker, so the splits are already loaded when it opens.
    final splits = ref.watch(splitOptionsProvider).value ?? const <Split>[];

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Save stays put: the fields below it scroll, and on a phone the button would
          // otherwise sit past the fold.
          Row(
            children: [
              Expanded(child: Text('Edit transaction', style: Theme.of(context).textTheme.titleLarge)),
              TextButton(
                key: const Key('transaction-save'),
                onPressed: state.isLoading ? null : _save,
                child: const Text('Save'),
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('transaction-name'),
                    controller: _name,
                    decoration: InputDecoration(labelText: 'Name', errorText: errors['/name']),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('transaction-amount'),
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(labelText: 'Amount', errorText: errors['/amount']),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    key: const Key('transaction-date'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    trailing: Text('$_date'),
                    onTap: _pickDate,
                  ),
                  const Divider(height: 24),
                  _allocations(budgets, splits, errors),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('transaction-note'),
                    controller: _note,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Note'),
                  ),
                  if (widget.transaction.transferId != null) ...[
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Part of a transfer'),
                      trailing: TextButton(
                        key: const Key('remove-transfer'),
                        onPressed: state.isLoading ? null : _removeTransfer,
                        child: const Text('Remove'),
                      ),
                    ),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          key: const Key('transaction-reviewed'),
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Reviewed'),
                          value: _reviewed,
                          onChanged: (value) => setState(() => _reviewed = value ?? false),
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          key: const Key('transaction-excluded'),
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Excluded'),
                          value: _excluded,
                          onChanged: (value) => setState(() => _excluded = value ?? false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _allocations(List<Budget> budgets, List<Split> splits, Map<String, String> errors) {
    // A transaction with one allocation splits nothing, so that line carries the whole amount and
    // only the budget is worth asking about.
    final single = _lines.length <= 1;
    final negative = (Decimal.tryParse(_amount.text.trim()) ?? Decimal.zero).sign < 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(negative ? 'Spend from' : 'Add to', style: const TextStyle(color: SpendableColors.muted)),
        const SizedBox(height: 8),
        for (final (index, line) in _lines.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    key: Key('allocation-budget-$index'),
                    initialValue: line.budgetId,
                    isExpanded: true,
                    items: [
                      for (final budget in budgets)
                        DropdownMenuItem(
                          value: budget.id,
                          child: Text(budget.name, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (value) => setState(() => line.budgetId = value),
                  ),
                ),
                if (!single) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      key: Key('allocation-amount-$index'),
                      controller: line.amount,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: InputDecoration(errorText: errors['/budget_allocations/$index/amount']),
                    ),
                  ),
                  IconButton(
                    key: Key('allocation-remove-$index'),
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => setState(() => _lines = [..._lines]..removeAt(index)),
                  ),
                ],
              ],
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(key: const Key('add-line'), onPressed: _addLine, child: const Text('Add line')),
            TextButton(
              key: const Key('apply-split'),
              onPressed: () => _pickSplit(splits),
              child: const Text('Apply split'),
            ),
          ],
        ),
      ],
    );
  }

  void _addLine() => setState(() => _lines = [..._lines, _Line(budgetId: null, amount: '')]);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.toDateTime(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) setState(() => _date = Date(picked.year, picked.month, picked.day));
  }

  /// Applying a split only rewrites the lines here; the server sees them on save like any others.
  Future<void> _pickSplit(List<Split> splits) async {
    final chosen = await showModalBottomSheet<Split>(
      context: context,
      builder: (_) => ListView(
        children: [
          for (final split in splits)
            ListTile(
              key: Key('split-${split.id}'),
              title: Text(split.name),
              onTap: () => Navigator.of(context).pop(split),
            ),
        ],
      ),
    );

    if (chosen == null) return;

    setState(() {
      _lines = [for (final line in chosen.splitLines) _Line(budgetId: line.budgetId, amount: line.amount)];
    });
  }

  Future<void> _save() async {
    final single = _lines.length <= 1;

    final allocations = [
      for (final line in _lines)
        BudgetAllocationRequest(
          (builder) => builder
            ..id = line.id
            ..budgetId = line.budgetId
            ..amount = single ? _amount.text.trim() : line.amount.text.trim(),
        ),
    ];

    final request = TransactionRequest(
      (builder) => builder
        ..name = _name.text
        ..amount = _amount.text.trim()
        ..date = _date
        ..note = _note.text.isEmpty ? null : _note.text
        ..reviewed = _reviewed
        ..excluded = _excluded
        ..budgetAllocations = ListBuilder(allocations),
    );

    final saved = await ref.read(transactionsControllerProvider.notifier).update(widget.transaction, request);

    if (saved && mounted) Navigator.of(context).pop();
  }

  Future<void> _removeTransfer() async {
    final removed = await ref
        .read(transactionsControllerProvider.notifier)
        .removeTransfer(widget.transaction);

    if (removed && mounted) Navigator.of(context).pop();
  }
}
