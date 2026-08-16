// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BulkRequest extends BulkRequest {
  @override
  final String? budgetId;
  @override
  final bool? excluded;
  @override
  final bool? reviewed;
  @override
  final BuiltList<String> transactionIds;

  factory _$BulkRequest([void Function(BulkRequestBuilder)? updates]) =>
      (BulkRequestBuilder()..update(updates))._build();

  _$BulkRequest._(
      {this.budgetId,
      this.excluded,
      this.reviewed,
      required this.transactionIds})
      : super._();
  @override
  BulkRequest rebuild(void Function(BulkRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BulkRequestBuilder toBuilder() => BulkRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BulkRequest &&
        budgetId == other.budgetId &&
        excluded == other.excluded &&
        reviewed == other.reviewed &&
        transactionIds == other.transactionIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, budgetId.hashCode);
    _$hash = $jc(_$hash, excluded.hashCode);
    _$hash = $jc(_$hash, reviewed.hashCode);
    _$hash = $jc(_$hash, transactionIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BulkRequest')
          ..add('budgetId', budgetId)
          ..add('excluded', excluded)
          ..add('reviewed', reviewed)
          ..add('transactionIds', transactionIds))
        .toString();
  }
}

class BulkRequestBuilder implements Builder<BulkRequest, BulkRequestBuilder> {
  _$BulkRequest? _$v;

  String? _budgetId;
  String? get budgetId => _$this._budgetId;
  set budgetId(String? budgetId) => _$this._budgetId = budgetId;

  bool? _excluded;
  bool? get excluded => _$this._excluded;
  set excluded(bool? excluded) => _$this._excluded = excluded;

  bool? _reviewed;
  bool? get reviewed => _$this._reviewed;
  set reviewed(bool? reviewed) => _$this._reviewed = reviewed;

  ListBuilder<String>? _transactionIds;
  ListBuilder<String> get transactionIds =>
      _$this._transactionIds ??= ListBuilder<String>();
  set transactionIds(ListBuilder<String>? transactionIds) =>
      _$this._transactionIds = transactionIds;

  BulkRequestBuilder() {
    BulkRequest._defaults(this);
  }

  BulkRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _budgetId = $v.budgetId;
      _excluded = $v.excluded;
      _reviewed = $v.reviewed;
      _transactionIds = $v.transactionIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BulkRequest other) {
    _$v = other as _$BulkRequest;
  }

  @override
  void update(void Function(BulkRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BulkRequest build() => _build();

  _$BulkRequest _build() {
    _$BulkRequest _$result;
    try {
      _$result = _$v ??
          _$BulkRequest._(
            budgetId: budgetId,
            excluded: excluded,
            reviewed: reviewed,
            transactionIds: transactionIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'transactionIds';
        transactionIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BulkRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
