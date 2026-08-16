// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_line.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SplitLine extends SplitLine {
  @override
  final String amount;
  @override
  final String budgetId;
  @override
  final String id;

  factory _$SplitLine([void Function(SplitLineBuilder)? updates]) =>
      (SplitLineBuilder()..update(updates))._build();

  _$SplitLine._(
      {required this.amount, required this.budgetId, required this.id})
      : super._();
  @override
  SplitLine rebuild(void Function(SplitLineBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SplitLineBuilder toBuilder() => SplitLineBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SplitLine &&
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
    return (newBuiltValueToStringHelper(r'SplitLine')
          ..add('amount', amount)
          ..add('budgetId', budgetId)
          ..add('id', id))
        .toString();
  }
}

class SplitLineBuilder implements Builder<SplitLine, SplitLineBuilder> {
  _$SplitLine? _$v;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _budgetId;
  String? get budgetId => _$this._budgetId;
  set budgetId(String? budgetId) => _$this._budgetId = budgetId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  SplitLineBuilder() {
    SplitLine._defaults(this);
  }

  SplitLineBuilder get _$this {
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
  void replace(SplitLine other) {
    _$v = other as _$SplitLine;
  }

  @override
  void update(void Function(SplitLineBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SplitLine build() => _build();

  _$SplitLine _build() {
    final _$result = _$v ??
        _$SplitLine._(
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'SplitLine', 'amount'),
          budgetId: BuiltValueNullFieldError.checkNotNull(
              budgetId, r'SplitLine', 'budgetId'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'SplitLine', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
