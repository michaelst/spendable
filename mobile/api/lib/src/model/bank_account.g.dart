// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_account.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BankAccount extends BankAccount {
  @override
  final String balance;
  @override
  final String? budgetId;
  @override
  final String id;
  @override
  final String name;
  @override
  final String? number;
  @override
  final String subType;
  @override
  final bool sync_;
  @override
  final String type;

  factory _$BankAccount([void Function(BankAccountBuilder)? updates]) =>
      (BankAccountBuilder()..update(updates))._build();

  _$BankAccount._(
      {required this.balance,
      this.budgetId,
      required this.id,
      required this.name,
      this.number,
      required this.subType,
      required this.sync_,
      required this.type})
      : super._();
  @override
  BankAccount rebuild(void Function(BankAccountBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BankAccountBuilder toBuilder() => BankAccountBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BankAccount &&
        balance == other.balance &&
        budgetId == other.budgetId &&
        id == other.id &&
        name == other.name &&
        number == other.number &&
        subType == other.subType &&
        sync_ == other.sync_ &&
        type == other.type;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, balance.hashCode);
    _$hash = $jc(_$hash, budgetId.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, number.hashCode);
    _$hash = $jc(_$hash, subType.hashCode);
    _$hash = $jc(_$hash, sync_.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BankAccount')
          ..add('balance', balance)
          ..add('budgetId', budgetId)
          ..add('id', id)
          ..add('name', name)
          ..add('number', number)
          ..add('subType', subType)
          ..add('sync_', sync_)
          ..add('type', type))
        .toString();
  }
}

class BankAccountBuilder implements Builder<BankAccount, BankAccountBuilder> {
  _$BankAccount? _$v;

  String? _balance;
  String? get balance => _$this._balance;
  set balance(String? balance) => _$this._balance = balance;

  String? _budgetId;
  String? get budgetId => _$this._budgetId;
  set budgetId(String? budgetId) => _$this._budgetId = budgetId;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _number;
  String? get number => _$this._number;
  set number(String? number) => _$this._number = number;

  String? _subType;
  String? get subType => _$this._subType;
  set subType(String? subType) => _$this._subType = subType;

  bool? _sync_;
  bool? get sync_ => _$this._sync_;
  set sync_(bool? sync_) => _$this._sync_ = sync_;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  BankAccountBuilder() {
    BankAccount._defaults(this);
  }

  BankAccountBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _balance = $v.balance;
      _budgetId = $v.budgetId;
      _id = $v.id;
      _name = $v.name;
      _number = $v.number;
      _subType = $v.subType;
      _sync_ = $v.sync_;
      _type = $v.type;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BankAccount other) {
    _$v = other as _$BankAccount;
  }

  @override
  void update(void Function(BankAccountBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BankAccount build() => _build();

  _$BankAccount _build() {
    final _$result = _$v ??
        _$BankAccount._(
          balance: BuiltValueNullFieldError.checkNotNull(
              balance, r'BankAccount', 'balance'),
          budgetId: budgetId,
          id: BuiltValueNullFieldError.checkNotNull(id, r'BankAccount', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'BankAccount', 'name'),
          number: number,
          subType: BuiltValueNullFieldError.checkNotNull(
              subType, r'BankAccount', 'subType'),
          sync_: BuiltValueNullFieldError.checkNotNull(
              sync_, r'BankAccount', 'sync_'),
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'BankAccount', 'type'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
