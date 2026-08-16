import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart' hide Split;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_error.dart';
import '../budgets/budgets_providers.dart';
import 'splits_controller.dart';

class _Line {
  _Line({this.id, this.budgetId, required String amount}) : amount = TextEditingController(text: amount);

  final String? id;
  final TextEditingController amount;

  String? budgetId;
}

/// Editing one split. The whole set of lines is sent every save: one with an id is kept, one
/// without is added, and one left out is deleted.
class SplitForm extends ConsumerStatefulWidget {
  const SplitForm({super.key, this.split});

  final Split? split;

  @override
  ConsumerState<SplitForm> createState() => _SplitFormState();
}

class _SplitFormState extends ConsumerState<SplitForm> {
  late final _name = TextEditingController(text: widget.split?.name ?? '');

  late var _lines = [
    for (final line in widget.split?.splitLines ?? const <SplitLine>[])
      _Line(id: line.id, budgetId: line.budgetId, amount: line.amount),
  ];

  @override
  void dispose() {
    _name.dispose();
    for (final line in _lines) {
      line.amount.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(splitsControllerProvider);
    final errors = state.error is ApiError
        ? (state.error! as ApiError).fieldErrors
        : const <String, String>{};
    final budgets = ref.watch(budgetOptionsProvider).value ?? const <Budget>[];

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
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.split == null ? 'New split' : 'Edit split',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                key: const Key('split-save'),
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
                    key: const Key('split-name'),
                    controller: _name,
                    decoration: InputDecoration(labelText: 'Name', errorText: errors['/name']),
                  ),
                  const SizedBox(height: 16),
                  for (final (index, line) in _lines.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              key: Key('split-budget-$index'),
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
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              key: Key('split-amount-$index'),
                              controller: line.amount,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              decoration: InputDecoration(errorText: errors['/split_lines/$index/amount']),
                            ),
                          ),
                          IconButton(
                            key: Key('split-remove-$index'),
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => setState(() => _lines = [..._lines]..removeAt(index)),
                          ),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      key: const Key('split-add-line'),
                      onPressed: () => setState(() => _lines = [..._lines, _Line(amount: '')]),
                      child: const Text('Add line'),
                    ),
                  ),
                  if (widget.split case final split?)
                    TextButton(
                      key: const Key('split-archive'),
                      onPressed: state.isLoading ? null : () => _archive(split.id),
                      style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                      child: const Text('Archive split'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final request = SplitRequest(
      (builder) => builder
        ..name = _name.text
        ..splitLines = ListBuilder([
          for (final line in _lines)
            SplitLineRequest(
              (entry) => entry
                ..id = line.id
                ..budgetId = line.budgetId
                ..amount = line.amount.text.trim(),
            ),
        ]),
    );

    await _close(ref.read(splitsControllerProvider.notifier).save(id: widget.split?.id, request: request));
  }

  Future<void> _archive(String id) => _close(ref.read(splitsControllerProvider.notifier).archive([id]));

  /// A failure keeps the sheet open so the field errors have somewhere to land.
  Future<void> _close(Future<bool> write) async {
    final saved = await write;

    if (saved && mounted) Navigator.of(context).pop();
  }
}
