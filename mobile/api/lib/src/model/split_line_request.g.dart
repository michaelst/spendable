// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_line_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SplitLineRequest extends SplitLineRequest {
  @override
  final String amount;
  @override
  final String budgetId;
  @override
  final String? id;

  factory _$SplitLineRequest(
          [void Function(SplitLineRequestBuilder)? updates]) =>
      (SplitLineRequestBuilder()..update(updates))._build();

  _$SplitLineRequest._({required this.amount, required this.budgetId, this.id})
      : super._();
  @override
  SplitLineRequest rebuild(void Function(SplitLineRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SplitLineRequestBuilder toBuilder() =>
      SplitLineRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SplitLineRequest &&
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
    return (newBuiltValueToStringHelper(r'SplitLineRequest')
          ..add('amount', amount)
          ..add('budgetId', budgetId)
          ..add('id', id))
        .toString();
  }
}

class SplitLineRequestBuilder
    implements Builder<SplitLineRequest, SplitLineRequestBuilder> {
  _$SplitLineRequest? _$v;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _budgetId;
  String? get budgetId => _$this._budgetId;
  set budgetId(String? budgetId) => _$this._budgetId = budgetId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  SplitLineRequestBuilder() {
    SplitLineRequest._defaults(this);
  }

  SplitLineRequestBuilder get _$this {
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
  void replace(SplitLineRequest other) {
    _$v = other as _$SplitLineRequest;
  }

  @override
  void update(void Function(SplitLineRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SplitLineRequest build() => _build();

  _$SplitLineRequest _build() {
    final _$result = _$v ??
        _$SplitLineRequest._(
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'SplitLineRequest', 'amount'),
          budgetId: BuiltValueNullFieldError.checkNotNull(
              budgetId, r'SplitLineRequest', 'budgetId'),
          id: id,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
