// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_source.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TransactionSource extends TransactionSource {
  @override
  final String accountId;
  @override
  final String accountName;
  @override
  final String? accountNumber;
  @override
  final bool memberHasLogo;
  @override
  final String memberId;
  @override
  final String memberName;
  @override
  final bool pending;

  factory _$TransactionSource(
          [void Function(TransactionSourceBuilder)? updates]) =>
      (TransactionSourceBuilder()..update(updates))._build();

  _$TransactionSource._(
      {required this.accountId,
      required this.accountName,
      this.accountNumber,
      required this.memberHasLogo,
      required this.memberId,
      required this.memberName,
      required this.pending})
      : super._();
  @override
  TransactionSource rebuild(void Function(TransactionSourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TransactionSourceBuilder toBuilder() =>
      TransactionSourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TransactionSource &&
        accountId == other.accountId &&
        accountName == other.accountName &&
        accountNumber == other.accountNumber &&
        memberHasLogo == other.memberHasLogo &&
        memberId == other.memberId &&
        memberName == other.memberName &&
        pending == other.pending;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accountId.hashCode);
    _$hash = $jc(_$hash, accountName.hashCode);
    _$hash = $jc(_$hash, accountNumber.hashCode);
    _$hash = $jc(_$hash, memberHasLogo.hashCode);
    _$hash = $jc(_$hash, memberId.hashCode);
    _$hash = $jc(_$hash, memberName.hashCode);
    _$hash = $jc(_$hash, pending.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TransactionSource')
          ..add('accountId', accountId)
          ..add('accountName', accountName)
          ..add('accountNumber', accountNumber)
          ..add('memberHasLogo', memberHasLogo)
          ..add('memberId', memberId)
          ..add('memberName', memberName)
          ..add('pending', pending))
        .toString();
  }
}

class TransactionSourceBuilder
    implements Builder<TransactionSource, TransactionSourceBuilder> {
  _$TransactionSource? _$v;

  String? _accountId;
  String? get accountId => _$this._accountId;
  set accountId(String? accountId) => _$this._accountId = accountId;

  String? _accountName;
  String? get accountName => _$this._accountName;
  set accountName(String? accountName) => _$this._accountName = accountName;

  String? _accountNumber;
  String? get accountNumber => _$this._accountNumber;
  set accountNumber(String? accountNumber) =>
      _$this._accountNumber = accountNumber;

  bool? _memberHasLogo;
  bool? get memberHasLogo => _$this._memberHasLogo;
  set memberHasLogo(bool? memberHasLogo) =>
      _$this._memberHasLogo = memberHasLogo;

  String? _memberId;
  String? get memberId => _$this._memberId;
  set memberId(String? memberId) => _$this._memberId = memberId;

  String? _memberName;
  String? get memberName => _$this._memberName;
  set memberName(String? memberName) => _$this._memberName = memberName;

  bool? _pending;
  bool? get pending => _$this._pending;
  set pending(bool? pending) => _$this._pending = pending;

  TransactionSourceBuilder() {
    TransactionSource._defaults(this);
  }

  TransactionSourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accountId = $v.accountId;
      _accountName = $v.accountName;
      _accountNumber = $v.accountNumber;
      _memberHasLogo = $v.memberHasLogo;
      _memberId = $v.memberId;
      _memberName = $v.memberName;
      _pending = $v.pending;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TransactionSource other) {
    _$v = other as _$TransactionSource;
  }

  @override
  void update(void Function(TransactionSourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TransactionSource build() => _build();

  _$TransactionSource _build() {
    final _$result = _$v ??
        _$TransactionSource._(
          accountId: BuiltValueNullFieldError.checkNotNull(
              accountId, r'TransactionSource', 'accountId'),
          accountName: BuiltValueNullFieldError.checkNotNull(
              accountName, r'TransactionSource', 'accountName'),
          accountNumber: accountNumber,
          memberHasLogo: BuiltValueNullFieldError.checkNotNull(
              memberHasLogo, r'TransactionSource', 'memberHasLogo'),
          memberId: BuiltValueNullFieldError.checkNotNull(
              memberId, r'TransactionSource', 'memberId'),
          memberName: BuiltValueNullFieldError.checkNotNull(
              memberName, r'TransactionSource', 'memberName'),
          pending: BuiltValueNullFieldError.checkNotNull(
              pending, r'TransactionSource', 'pending'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
