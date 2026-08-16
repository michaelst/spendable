// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_allocation_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BudgetAllocationRequest extends BudgetAllocationRequest {
  @override
  final String amount;
  @override
  final String budgetId;
  @override
  final String? id;

  factory _$BudgetAllocationRequest(
          [void Function(BudgetAllocationRequestBuilder)? updates]) =>
      (BudgetAllocationRequestBuilder()..update(updates))._build();

  _$BudgetAllocationRequest._(
      {required this.amount, required this.budgetId, this.id})
      : super._();
  @override
  BudgetAllocationRequest rebuild(
          void Function(BudgetAllocationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BudgetAllocationRequestBuilder toBuilder() =>
      BudgetAllocationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BudgetAllocationRequest &&
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
    return (newBuiltValueToStringHelper(r'BudgetAllocationRequest')
          ..add('amount', amount)
          ..add('budgetId', budgetId)
          ..add('id', id))
        .toString();
  }
}

class BudgetAllocationRequestBuilder
    implements
        Builder<BudgetAllocationRequest, BudgetAllocationRequestBuilder> {
  _$BudgetAllocationRequest? _$v;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _budgetId;
  String? get budgetId => _$this._budgetId;
  set budgetId(String? budgetId) => _$this._budgetId = budgetId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  BudgetAllocationRequestBuilder() {
    BudgetAllocationRequest._defaults(this);
  }

  BudgetAllocationRequestBuilder get _$this {
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
  void replace(BudgetAllocationRequest other) {
    _$v = other as _$BudgetAllocationRequest;
  }

  @override
  void update(void Function(BudgetAllocationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BudgetAllocationRequest build() => _build();

  _$BudgetAllocationRequest _build() {
    final _$result = _$v ??
        _$BudgetAllocationRequest._(
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'BudgetAllocationRequest', 'amount'),
          budgetId: BuiltValueNullFieldError.checkNotNull(
              budgetId, r'BudgetAllocationRequest', 'budgetId'),
          id: id,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
