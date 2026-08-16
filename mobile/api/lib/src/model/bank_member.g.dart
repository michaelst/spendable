// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_member.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BankMember extends BankMember {
  @override
  final BuiltList<BankAccount> bankAccounts;
  @override
  final bool hasLogo;
  @override
  final String id;
  @override
  final String name;
  @override
  final String provider;
  @override
  final String? status;

  factory _$BankMember([void Function(BankMemberBuilder)? updates]) =>
      (BankMemberBuilder()..update(updates))._build();

  _$BankMember._(
      {required this.bankAccounts,
      required this.hasLogo,
      required this.id,
      required this.name,
      required this.provider,
      this.status})
      : super._();
  @override
  BankMember rebuild(void Function(BankMemberBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BankMemberBuilder toBuilder() => BankMemberBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BankMember &&
        bankAccounts == other.bankAccounts &&
        hasLogo == other.hasLogo &&
        id == other.id &&
        name == other.name &&
        provider == other.provider &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bankAccounts.hashCode);
    _$hash = $jc(_$hash, hasLogo.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BankMember')
          ..add('bankAccounts', bankAccounts)
          ..add('hasLogo', hasLogo)
          ..add('id', id)
          ..add('name', name)
          ..add('provider', provider)
          ..add('status', status))
        .toString();
  }
}

class BankMemberBuilder implements Builder<BankMember, BankMemberBuilder> {
  _$BankMember? _$v;

  ListBuilder<BankAccount>? _bankAccounts;
  ListBuilder<BankAccount> get bankAccounts =>
      _$this._bankAccounts ??= ListBuilder<BankAccount>();
  set bankAccounts(ListBuilder<BankAccount>? bankAccounts) =>
      _$this._bankAccounts = bankAccounts;

  bool? _hasLogo;
  bool? get hasLogo => _$this._hasLogo;
  set hasLogo(bool? hasLogo) => _$this._hasLogo = hasLogo;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  BankMemberBuilder() {
    BankMember._defaults(this);
  }

  BankMemberBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bankAccounts = $v.bankAccounts.toBuilder();
      _hasLogo = $v.hasLogo;
      _id = $v.id;
      _name = $v.name;
      _provider = $v.provider;
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BankMember other) {
    _$v = other as _$BankMember;
  }

  @override
  void update(void Function(BankMemberBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BankMember build() => _build();

  _$BankMember _build() {
    _$BankMember _$result;
    try {
      _$result = _$v ??
          _$BankMember._(
            bankAccounts: bankAccounts.build(),
            hasLogo: BuiltValueNullFieldError.checkNotNull(
                hasLogo, r'BankMember', 'hasLogo'),
            id: BuiltValueNullFieldError.checkNotNull(id, r'BankMember', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'BankMember', 'name'),
            provider: BuiltValueNullFieldError.checkNotNull(
                provider, r'BankMember', 'provider'),
            status: status,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'bankAccounts';
        bankAccounts.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BankMember', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
