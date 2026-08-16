import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart' hide Split;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_error.dart';
import '../budgets/budget_picker.dart';
import '../budgets/budgets_providers.dart';
import '../design/band_button.dart';
import '../design/glyph_icon.dart';
import '../design/picker_field.dart';
import '../design/primary_button.dart';
import '../design/sheet_header.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
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
    final colors = SpendableColors.of(context);
    final state = ref.watch(splitsControllerProvider);
    final errors = state.error is ApiError
        ? (state.error! as ApiError).fieldErrors
        : const <String, String>{};
    final budgets = ref.watch(budgetOptionsProvider).value ?? const <Budget>[];

    return Padding(
      padding: EdgeInsets.only(
        left: SpendableSpace.gutter,
        right: SpendableSpace.gutter,
        top: SpendableSpace.step,
        bottom: MediaQuery.viewInsetsOf(context).bottom + SpendableSpace.block,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(
            title: widget.split == null ? 'New split' : 'Edit split',
            action: BandButton(
              key: const Key('split-save'),
              label: 'Save',
              onPressed: state.isLoading ? null : _save,
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const Key('split-name'),
                    controller: _name,
                    style: SpendableType.body.copyWith(color: colors.primary),
                    decoration: InputDecoration(labelText: 'Name', errorText: errors['/name']),
                  ),
                  const SizedBox(height: SpendableSpace.gutter),
                  for (final (index, line) in _lines.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: SpendableSpace.tight),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: PickerField(
                              key: Key('split-budget-$index'),
                              label: 'Budget',
                              value: budgets.where((budget) => budget.id == line.budgetId).firstOrNull?.name,
                              onTap: () async {
                                final chosen = await pickBudget(context);

                                if (chosen != null) setState(() => line.budgetId = chosen.id);
                              },
                            ),
                          ),
                          const SizedBox(width: SpendableSpace.tight),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              key: Key('split-amount-$index'),
                              controller: line.amount,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              textAlign: TextAlign.right,
                              style: SpendableType.moneyInline.copyWith(color: colors.primary),
                              decoration: InputDecoration(errorText: errors['/split_lines/$index/amount']),
                            ),
                          ),
                          GestureDetector(
                            key: Key('split-remove-$index'),
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _lines = [..._lines]..removeAt(index)),
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: Center(
                                child: GlyphIcon(Glyph.minusCircle, size: 20, color: colors.tertiary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: BandButton(
                      key: const Key('split-add-line'),
                      label: 'Add line',
                      onPressed: () => setState(() => _lines = [..._lines, _Line(amount: '')]),
                    ),
                  ),
                  if (widget.split case final split?) ...[
                    const SizedBox(height: SpendableSpace.step),
                    PrimaryButton(
                      key: const Key('split-archive'),
                      label: 'Archive split',
                      variant: ButtonVariant.destructive,
                      onPressed: state.isLoading ? null : () => _archive(split.id),
                    ),
                  ],
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
