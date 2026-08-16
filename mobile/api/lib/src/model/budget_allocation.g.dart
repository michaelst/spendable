// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_allocation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BudgetAllocation extends BudgetAllocation {
  @override
  final String amount;
  @override
  final String budgetId;
  @override
  final String id;

  factory _$BudgetAllocation(
          [void Function(BudgetAllocationBuilder)? updates]) =>
      (BudgetAllocationBuilder()..update(updates))._build();

  _$BudgetAllocation._(
      {required this.amount, required this.budgetId, required this.id})
      : super._();
  @override
  BudgetAllocation rebuild(void Function(BudgetAllocationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BudgetAllocationBuilder toBuilder() =>
      BudgetAllocationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BudgetAllocation &&
        amount == other.amount &&
        budgetId == other.budgetId &&
        id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, budgetId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BudgetAllocation')
          ..add('amount', amount)
          ..add('budgetId', budgetId)
          ..add('id', id))
        .toString();
  }
}

class BudgetAllocationBuilder
    implements Builder<BudgetAllocation, BudgetAllocationBuilder> {
  _$BudgetAllocation? _$v;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _budgetId;
  String? get budgetId => _$this._budgetId;
  set budgetId(String? budgetId) => _$this._budgetId = budgetId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  BudgetAllocationBuilder() {
    BudgetAllocation._defaults(this);
  }

  BudgetAllocationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _amount = $v.amount;
      _budgetId = $v.budgetId;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BudgetAllocation other) {
    _$v = other as _$BudgetAllocation;
  }

  @override
  void update(void Function(BudgetAllocationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BudgetAllocation build() => _build();

  _$BudgetAllocation _build() {
    final _$result = _$v ??
        _$BudgetAllocation._(
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'BudgetAllocation', 'amount'),
          budgetId: BuiltValueNullFieldError.checkNotNull(
              budgetId, r'BudgetAllocation', 'budgetId'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'BudgetAllocation', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
