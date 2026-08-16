// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TransactionRequest extends TransactionRequest {
  @override
  final String? amount;
  @override
  final BuiltList<BudgetAllocationRequest>? budgetAllocations;
  @override
  final Date? date;
  @override
  final bool? excluded;
  @override
  final String? name;
  @override
  final String? note;
  @override
  final bool? reviewed;

  factory _$TransactionRequest(
          [void Function(TransactionRequestBuilder)? updates]) =>
      (TransactionRequestBuilder()..update(updates))._build();

  _$TransactionRequest._(
      {this.amount,
      this.budgetAllocations,
      this.date,
      this.excluded,
      this.name,
      this.note,
      this.reviewed})
      : super._();
  @override
  TransactionRequest rebuild(
          void Function(TransactionRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TransactionRequestBuilder toBuilder() =>
      TransactionRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TransactionRequest &&
        amount == other.amount &&
        budgetAllocations == other.budgetAllocations &&
        date == other.date &&
        excluded == other.excluded &&
        name == other.name &&
        note == other.note &&
        reviewed == other.reviewed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, budgetAllocations.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, excluded.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, reviewed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TransactionRequest')
          ..add('amount', amount)
          ..add('budgetAllocations', budgetAllocations)
          ..add('date', date)
          ..add('excluded', excluded)
          ..add('name', name)
          ..add('note', note)
          ..add('reviewed', reviewed))
        .toString();
  }
}

class TransactionRequestBuilder
    implements Builder<TransactionRequest, TransactionRequestBuilder> {
  _$TransactionRequest? _$v;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  ListBuilder<BudgetAllocationRequest>? _budgetAllocations;
  ListBuilder<BudgetAllocationRequest> get budgetAllocations =>
      _$this._budgetAllocations ??= ListBuilder<BudgetAllocationRequest>();
  set budgetAllocations(
          ListBuilder<BudgetAllocationRequest>? budgetAllocations) =>
      _$this._budgetAllocations = budgetAllocations;

  Date? _date;
  Date? get date => _$this._date;
  set date(Date? date) => _$this._date = date;

  bool? _excluded;
  bool? get excluded => _$this._excluded;
  set excluded(bool? excluded) => _$this._excluded = excluded;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  bool? _reviewed;
  bool? get reviewed => _$this._reviewed;
  set reviewed(bool? reviewed) => _$this._reviewed = reviewed;

  TransactionRequestBuilder() {
    TransactionRequest._defaults(this);
  }

  TransactionRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _amount = $v.amount;
      _budgetAllocations = $v.budgetAllocations?.toBuilder();
      _date = $v.date;
      _excluded = $v.excluded;
      _name = $v.name;
      _note = $v.note;
      _reviewed = $v.reviewed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TransactionRequest other) {
    _$v = other as _$TransactionRequest;
  }

  @override
  void update(void Function(TransactionRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TransactionRequest build() => _build();

  _$TransactionRequest _build() {
    _$TransactionRequest _$result;
    try {
      _$result = _$v ??
          _$TransactionRequest._(
            amount: amount,
            budgetAllocations: _budgetAllocations?.build(),
            date: date,
            excluded: excluded,
            name: name,
            note: note,
            reviewed: reviewed,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'budgetAllocations';
        _budgetAllocations?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TransactionRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
