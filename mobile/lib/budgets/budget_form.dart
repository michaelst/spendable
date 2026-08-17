import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendable_api/spendable_api.dart';

import '../api/api_error.dart';
import '../design/primary_button.dart';
import '../design/sheet_header.dart';
import '../design/tokens.dart';
import '../design/typography.dart';
import 'budgets_controller.dart';

const _types = {
  BudgetRequestTypeEnum.envelope: 'Envelope',
  BudgetRequestTypeEnum.goal: 'Goal',
  BudgetRequestTypeEnum.income: 'Income',
  BudgetRequestTypeEnum.tracking: 'Tracking',
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

  late final _fundingAmount = TextEditingController(text: widget.budget?.fundingAmount ?? '');

  late var _type = switch (widget.budget?.type) {
    BudgetTypeEnum.goal => BudgetRequestTypeEnum.goal,
    BudgetTypeEnum.tracking => BudgetRequestTypeEnum.tracking,
    BudgetTypeEnum.income => BudgetRequestTypeEnum.income,
    _ => BudgetRequestTypeEnum.envelope,
  };

  /// Off means the month tops the envelope back up to its amount, so an overspend does not follow
  /// it into the next month and leftover does not pile up.
  late var _rollover = widget.budget?.rollover ?? true;

  @override
  void dispose() {
    _name.dispose();
    _budgetedAmount.dispose();
    _fundingAmount.dispose();
    _balance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SpendableColors.of(context);
    final state = ref.watch(budgetsControllerProvider);
    final errors = state.error is ApiError
        ? (state.error! as ApiError).fieldErrors
        : const <String, String>{};
    // Tracking and income record a month and hold nothing, so neither has a balance to allocate.
    final holdsMoney =
        _type == BudgetRequestTypeEnum.envelope || _type == BudgetRequestTypeEnum.goal;

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
          SheetHeader(title: widget.budget == null ? 'New budget' : 'Edit budget'),
          const SizedBox(height: SpendableSpace.step),
          TextField(
            key: const Key('budget-name'),
            controller: _name,
            style: SpendableType.body.copyWith(color: colors.primary),
            decoration: InputDecoration(labelText: 'Name', errorText: errors['/name']),
          ),
          const SizedBox(height: SpendableSpace.gutter),
          CupertinoSlidingSegmentedControl<BudgetRequestTypeEnum>(
            key: const Key('budget-type'),
            groupValue: _type,
            backgroundColor: colors.separator,
            thumbColor: colors.ground,
            children: {
              for (final entry in _types.entries)
                entry.key: Padding(
                  padding: const EdgeInsets.symmetric(vertical: SpendableSpace.tight),
                  child: Text(entry.value, style: SpendableType.body.copyWith(color: colors.primary)),
                ),
            },
            onValueChanged: (value) => setState(() => _type = value ?? _type),
          ),
          const SizedBox(height: SpendableSpace.tight),
          TextField(
            key: const Key('budget-amount'),
            controller: _budgetedAmount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: SpendableType.moneyInline.copyWith(color: colors.primary),
            decoration: InputDecoration(
              labelText: _amountLabel,
              errorText: errors['/budgeted_amount'],
            ),
          ),
          if (_type == BudgetRequestTypeEnum.envelope) ...[
            const SizedBox(height: SpendableSpace.gutter),
            // Its own amount rather than a switch tied to the budgeted one: a user can measure
            // spending against 400 while only being able to put 300 in. Blank means it does not
            // fund itself and the user fills it.
            TextField(
              key: const Key('budget-funding'),
              controller: _fundingAmount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: SpendableType.moneyInline.copyWith(color: colors.primary),
              decoration: InputDecoration(
                labelText: 'Fund each month',
                errorText: errors['/funding_amount'],
              ),
            ),
            const SizedBox(height: SpendableSpace.tight),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Carry the balance into next month',
                    style: SpendableType.body.copyWith(color: colors.primary),
                  ),
                ),
                CupertinoSwitch(
                  key: const Key('budget-rollover'),
                  value: _rollover,
                  onChanged: (value) => setState(() => _rollover = value),
                ),
              ],
            ),
          ],
          if (_type == BudgetRequestTypeEnum.goal) ...[
            const SizedBox(height: SpendableSpace.gutter),
            TextField(
              key: const Key('budget-funding'),
              controller: _fundingAmount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: SpendableType.moneyInline.copyWith(color: colors.primary),
              decoration: InputDecoration(
                labelText: 'Monthly contribution',
                errorText: errors['/funding_amount'],
              ),
            ),
          ],
          if (holdsMoney) ...[
            const SizedBox(height: SpendableSpace.gutter),
            TextField(
              key: const Key('budget-balance'),
              controller: _balance,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              style: SpendableType.moneyInline.copyWith(color: colors.primary),
              decoration: InputDecoration(labelText: 'Allocated', errorText: errors['/balance']),
            ),
          ],
          const SizedBox(height: SpendableSpace.block),
          PrimaryButton(
            key: const Key('budget-save'),
            label: 'Save',
            onPressed: state.isLoading ? null : _save,
          ),
          if (widget.budget case final budget?) ...[
            const SizedBox(height: SpendableSpace.tight),
            PrimaryButton(
              key: const Key('budget-archive'),
              label: 'Archive budget',
              variant: ButtonVariant.destructive,
              onPressed: state.isLoading ? null : () => _archive(budget.id),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    final holdsMoney =
        _type == BudgetRequestTypeEnum.envelope || _type == BudgetRequestTypeEnum.goal;

    final request = BudgetRequest(
      (builder) => builder
        ..name = _name.text
        ..type = _type
        ..budgetedAmount = _blankToNull(_budgetedAmount.text)
        ..fundingAmount = _fundsItself()
        ..rollover = _type == BudgetRequestTypeEnum.envelope ? _rollover : true
        ..balance = holdsMoney ? _blankToNull(_balance.text) : null,
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

  String get _amountLabel => switch (_type) {
    BudgetRequestTypeEnum.goal => 'Goal amount',
    BudgetRequestTypeEnum.income => 'Expected each month',
    BudgetRequestTypeEnum.tracking => 'Monthly limit',
    _ => 'Budgeted amount',
  };

  /// Only a budget that holds money can fund itself. Blank means it does not, and the user fills
  /// it themselves.
  String? _fundsItself() => switch (_type) {
    BudgetRequestTypeEnum.envelope || BudgetRequestTypeEnum.goal => _blankToNull(_fundingAmount.text),
    _ => null,
  };
}
