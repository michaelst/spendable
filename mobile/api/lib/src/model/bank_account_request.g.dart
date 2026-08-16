// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_account_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BankAccountRequest extends BankAccountRequest {
  @override
  final String? budgetId;
  @override
  final bool? sync_;

  factory _$BankAccountRequest(
          [void Function(BankAccountRequestBuilder)? updates]) =>
      (BankAccountRequestBuilder()..update(updates))._build();

  _$BankAccountRequest._({this.budgetId, this.sync_}) : super._();
  @override
  BankAccountRequest rebuild(
          void Function(BankAccountRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BankAccountRequestBuilder toBuilder() =>
      BankAccountRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BankAccountRequest &&
        budgetId == other.budgetId &&
        sync_ == other.sync_;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, budgetId.hashCode);
    _$hash = $jc(_$hash, sync_.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BankAccountRequest')
          ..add('budgetId', budgetId)
          ..add('sync_', sync_))
        .toString();
  }
}

class BankAccountRequestBuilder
    implements Builder<BankAccountRequest, BankAccountRequestBuilder> {
  _$BankAccountRequest? _$v;

  String? _budgetId;
  String? get budgetId => _$this._budgetId;
  set budgetId(String? budgetId) => _$this._budgetId = budgetId;

  bool? _sync_;
  bool? get sync_ => _$this._sync_;
  set sync_(bool? sync_) => _$this._sync_ = sync_;

  BankAccountRequestBuilder() {
    BankAccountRequest._defaults(this);
  }

  BankAccountRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _budgetId = $v.budgetId;
      _sync_ = $v.sync_;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BankAccountRequest other) {
    _$v = other as _$BankAccountRequest;
  }

  @override
  void update(void Function(BankAccountRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BankAccountRequest build() => _build();

  _$BankAccountRequest _build() {
    final _$result = _$v ??
        _$BankAccountRequest._(
          budgetId: budgetId,
          sync_: sync_,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
