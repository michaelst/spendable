// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TransferRequest extends TransferRequest {
  @override
  final BuiltList<String> transactionIds;

  factory _$TransferRequest([void Function(TransferRequestBuilder)? updates]) =>
      (TransferRequestBuilder()..update(updates))._build();

  _$TransferRequest._({required this.transactionIds}) : super._();
  @override
  TransferRequest rebuild(void Function(TransferRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TransferRequestBuilder toBuilder() => TransferRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TransferRequest && transactionIds == other.transactionIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, transactionIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TransferRequest')
          ..add('transactionIds', transactionIds))
        .toString();
  }
}

class TransferRequestBuilder
    implements Builder<TransferRequest, TransferRequestBuilder> {
  _$TransferRequest? _$v;

  ListBuilder<String>? _transactionIds;
  ListBuilder<String> get transactionIds =>
      _$this._transactionIds ??= ListBuilder<String>();
  set transactionIds(ListBuilder<String>? transactionIds) =>
      _$this._transactionIds = transactionIds;

  TransferRequestBuilder() {
    TransferRequest._defaults(this);
  }

  TransferRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _transactionIds = $v.transactionIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TransferRequest other) {
    _$v = other as _$TransferRequest;
  }

  @override
  void update(void Function(TransferRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TransferRequest build() => _build();

  _$TransferRequest _build() {
    _$TransferRequest _$result;
    try {
      _$result = _$v ??
          _$TransferRequest._(
            transactionIds: transactionIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'transactionIds';
        transactionIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'TransferRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
