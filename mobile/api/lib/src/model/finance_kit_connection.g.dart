// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_kit_connection.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FinanceKitConnection extends FinanceKitConnection {
  @override
  final BuiltList<BankAccount> bankAccounts;
  @override
  final String? historyToken;
  @override
  final String id;
  @override
  final String name;

  factory _$FinanceKitConnection(
          [void Function(FinanceKitConnectionBuilder)? updates]) =>
      (FinanceKitConnectionBuilder()..update(updates))._build();

  _$FinanceKitConnection._(
      {required this.bankAccounts,
      this.historyToken,
      required this.id,
      required this.name})
      : super._();
  @override
  FinanceKitConnection rebuild(
          void Function(FinanceKitConnectionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FinanceKitConnectionBuilder toBuilder() =>
      FinanceKitConnectionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FinanceKitConnection &&
        bankAccounts == other.bankAccounts &&
        historyToken == other.historyToken &&
        id == other.id &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bankAccounts.hashCode);
    _$hash = $jc(_$hash, historyToken.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FinanceKitConnection')
          ..add('bankAccounts', bankAccounts)
          ..add('historyToken', historyToken)
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class FinanceKitConnectionBuilder
    implements Builder<FinanceKitConnection, FinanceKitConnectionBuilder> {
  _$FinanceKitConnection? _$v;

  ListBuilder<BankAccount>? _bankAccounts;
  ListBuilder<BankAccount> get bankAccounts =>
      _$this._bankAccounts ??= ListBuilder<BankAccount>();
  set bankAccounts(ListBuilder<BankAccount>? bankAccounts) =>
      _$this._bankAccounts = bankAccounts;

  String? _historyToken;
  String? get historyToken => _$this._historyToken;
  set historyToken(String? historyToken) => _$this._historyToken = historyToken;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  FinanceKitConnectionBuilder() {
    FinanceKitConnection._defaults(this);
  }

  FinanceKitConnectionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bankAccounts = $v.bankAccounts.toBuilder();
      _historyToken = $v.historyToken;
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FinanceKitConnection other) {
    _$v = other as _$FinanceKitConnection;
  }

  @override
  void update(void Function(FinanceKitConnectionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FinanceKitConnection build() => _build();

  _$FinanceKitConnection _build() {
    _$FinanceKitConnection _$result;
    try {
      _$result = _$v ??
          _$FinanceKitConnection._(
            bankAccounts: bankAccounts.build(),
            historyToken: historyToken,
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'FinanceKitConnection', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'FinanceKitConnection', 'name'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'bankAccounts';
        bankAccounts.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FinanceKitConnection', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
