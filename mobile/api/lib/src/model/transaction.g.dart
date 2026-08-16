// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Transaction extends Transaction {
  @override
  final String amount;
  @override
  final BuiltList<BudgetAllocation> budgetAllocations;
  @override
  final Date date;
  @override
  final bool excluded;
  @override
  final String id;
  @override
  final String name;
  @override
  final String? note;
  @override
  final bool reviewed;
  @override
  final TransactionSource? source_;
  @override
  final String? transferId;

  factory _$Transaction([void Function(TransactionBuilder)? updates]) =>
      (TransactionBuilder()..update(updates))._build();

  _$Transaction._(
      {required this.amount,
      required this.budgetAllocations,
      required this.date,
      required this.excluded,
      required this.id,
      required this.name,
      this.note,
      required this.reviewed,
      this.source_,
      this.transferId})
      : super._();
  @override
  Transaction rebuild(void Function(TransactionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TransactionBuilder toBuilder() => TransactionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Transaction &&
        amount == other.amount &&
        budgetAllocations == other.budgetAllocations &&
        date == other.date &&
        excluded == other.excluded &&
        id == other.id &&
        name == other.name &&
        note == other.note &&
        reviewed == other.reviewed &&
        source_ == other.source_ &&
        transferId == other.transferId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, budgetAllocations.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, excluded.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, reviewed.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, transferId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Transaction')
          ..add('amount', amount)
          ..add('budgetAllocations', budgetAllocations)
          ..add('date', date)
          ..add('excluded', excluded)
          ..add('id', id)
          ..add('name', name)
          ..add('note', note)
          ..add('reviewed', reviewed)
          ..add('source_', source_)
          ..add('transferId', transferId))
        .toString();
  }
}

class TransactionBuilder implements Builder<Transaction, TransactionBuilder> {
  _$Transaction? _$v;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  ListBuilder<BudgetAllocation>? _budgetAllocations;
  ListBuilder<BudgetAllocation> get budgetAllocations =>
      _$this._budgetAllocations ??= ListBuilder<BudgetAllocation>();
  set budgetAllocations(ListBuilder<BudgetAllocation>? budgetAllocations) =>
      _$this._budgetAllocations = budgetAllocations;

  Date? _date;
  Date? get date => _$this._date;
  set date(Date? date) => _$this._date = date;

  bool? _excluded;
  bool? get excluded => _$this._excluded;
  set excluded(bool? excluded) => _$this._excluded = excluded;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  bool? _reviewed;
  bool? get reviewed => _$this._reviewed;
  set reviewed(bool? reviewed) => _$this._reviewed = reviewed;

  TransactionSourceBuilder? _source_;
  TransactionSourceBuilder get source_ =>
      _$this._source_ ??= TransactionSourceBuilder();
  set source_(TransactionSourceBuilder? source_) => _$this._source_ = source_;

  String? _transferId;
  String? get transferId => _$this._transferId;
  set transferId(String? transferId) => _$this._transferId = transferId;

  TransactionBuilder() {
    Transaction._defaults(this);
  }

  TransactionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _amount = $v.amount;
      _budgetAllocations = $v.budgetAllocations.toBuilder();
      _date = $v.date;
      _excluded = $v.excluded;
      _id = $v.id;
      _name = $v.name;
      _note = $v.note;
      _reviewed = $v.reviewed;
      _source_ = $v.source_?.toBuilder();
      _transferId = $v.transferId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Transaction other) {
    _$v = other as _$Transaction;
  }

  @override
  void update(void Function(TransactionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Transaction build() => _build();

  _$Transaction _build() {
    _$Transaction _$result;
    try {
      _$result = _$v ??
          _$Transaction._(
            amount: BuiltValueNullFieldError.checkNotNull(
                amount, r'Transaction', 'amount'),
            budgetAllocations: budgetAllocations.build(),
            date: BuiltValueNullFieldError.checkNotNull(
                date, r'Transaction', 'date'),
            excluded: BuiltValueNullFieldError.checkNotNull(
                excluded, r'Transaction', 'excluded'),
            id: BuiltValueNullFieldError.checkNotNull(id, r'Transaction', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'Transaction', 'name'),
            note: note,
            reviewed: BuiltValueNullFieldError.checkNotNull(
                reviewed, r'Transaction', 'reviewed'),
            source_: _source_?.build(),
            transferId: transferId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'budgetAllocations';
        budgetAllocations.build();

        _$failedField = 'source_';
        _source_?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Transaction', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
