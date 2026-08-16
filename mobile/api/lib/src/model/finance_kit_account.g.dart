// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_kit_account.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FinanceKitAccountCreditDebitIndicatorEnum
    _$financeKitAccountCreditDebitIndicatorEnum_credit =
    const FinanceKitAccountCreditDebitIndicatorEnum._('credit');
const FinanceKitAccountCreditDebitIndicatorEnum
    _$financeKitAccountCreditDebitIndicatorEnum_debit =
    const FinanceKitAccountCreditDebitIndicatorEnum._('debit');

FinanceKitAccountCreditDebitIndicatorEnum
    _$financeKitAccountCreditDebitIndicatorEnumValueOf(String name) {
  switch (name) {
    case 'credit':
      return _$financeKitAccountCreditDebitIndicatorEnum_credit;
    case 'debit':
      return _$financeKitAccountCreditDebitIndicatorEnum_debit;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<FinanceKitAccountCreditDebitIndicatorEnum>
    _$financeKitAccountCreditDebitIndicatorEnumValues = BuiltSet<
        FinanceKitAccountCreditDebitIndicatorEnum>(const <FinanceKitAccountCreditDebitIndicatorEnum>[
  _$financeKitAccountCreditDebitIndicatorEnum_credit,
  _$financeKitAccountCreditDebitIndicatorEnum_debit,
]);

const FinanceKitAccountKindEnum _$financeKitAccountKindEnum_creditCard =
    const FinanceKitAccountKindEnum._('creditCard');
const FinanceKitAccountKindEnum _$financeKitAccountKindEnum_cash =
    const FinanceKitAccountKindEnum._('cash');
const FinanceKitAccountKindEnum _$financeKitAccountKindEnum_savings =
    const FinanceKitAccountKindEnum._('savings');

FinanceKitAccountKindEnum _$financeKitAccountKindEnumValueOf(String name) {
  switch (name) {
    case 'creditCard':
      return _$financeKitAccountKindEnum_creditCard;
    case 'cash':
      return _$financeKitAccountKindEnum_cash;
    case 'savings':
      return _$financeKitAccountKindEnum_savings;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<FinanceKitAccountKindEnum> _$financeKitAccountKindEnumValues =
    BuiltSet<FinanceKitAccountKindEnum>(const <FinanceKitAccountKindEnum>[
  _$financeKitAccountKindEnum_creditCard,
  _$financeKitAccountKindEnum_cash,
  _$financeKitAccountKindEnum_savings,
]);

Serializer<FinanceKitAccountCreditDebitIndicatorEnum>
    _$financeKitAccountCreditDebitIndicatorEnumSerializer =
    _$FinanceKitAccountCreditDebitIndicatorEnumSerializer();
Serializer<FinanceKitAccountKindEnum> _$financeKitAccountKindEnumSerializer =
    _$FinanceKitAccountKindEnumSerializer();

class _$FinanceKitAccountCreditDebitIndicatorEnumSerializer
    implements PrimitiveSerializer<FinanceKitAccountCreditDebitIndicatorEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'credit': 'credit',
    'debit': 'debit',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'credit': 'credit',
    'debit': 'debit',
  };

  @override
  final Iterable<Type> types = const <Type>[
    FinanceKitAccountCreditDebitIndicatorEnum
  ];
  @override
  final String wireName = 'FinanceKitAccountCreditDebitIndicatorEnum';

  @override
  Object serialize(Serializers serializers,
          FinanceKitAccountCreditDebitIndicatorEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  FinanceKitAccountCreditDebitIndicatorEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      FinanceKitAccountCreditDebitIndicatorEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$FinanceKitAccountKindEnumSerializer
    implements PrimitiveSerializer<FinanceKitAccountKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'creditCard': 'credit_card',
    'cash': 'cash',
    'savings': 'savings',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'credit_card': 'creditCard',
    'cash': 'cash',
    'savings': 'savings',
  };

  @override
  final Iterable<Type> types = const <Type>[FinanceKitAccountKindEnum];
  @override
  final String wireName = 'FinanceKitAccountKindEnum';

  @override
  Object serialize(Serializers serializers, FinanceKitAccountKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  FinanceKitAccountKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      FinanceKitAccountKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$FinanceKitAccount extends FinanceKitAccount {
  @override
  final String balance;
  @override
  final FinanceKitAccountCreditDebitIndicatorEnum creditDebitIndicator;
  @override
  final String externalId;
  @override
  final FinanceKitAccountKindEnum kind;
  @override
  final String name;

  factory _$FinanceKitAccount(
          [void Function(FinanceKitAccountBuilder)? updates]) =>
      (FinanceKitAccountBuilder()..update(updates))._build();

  _$FinanceKitAccount._(
      {required this.balance,
      required this.creditDebitIndicator,
      required this.externalId,
      required this.kind,
      required this.name})
      : super._();
  @override
  FinanceKitAccount rebuild(void Function(FinanceKitAccountBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FinanceKitAccountBuilder toBuilder() =>
      FinanceKitAccountBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FinanceKitAccount &&
        balance == other.balance &&
        creditDebitIndicator == other.creditDebitIndicator &&
        externalId == other.externalId &&
        kind == other.kind &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, balance.hashCode);
    _$hash = $jc(_$hash, creditDebitIndicator.hashCode);
    _$hash = $jc(_$hash, externalId.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FinanceKitAccount')
          ..add('balance', balance)
          ..add('creditDebitIndicator', creditDebitIndicator)
          ..add('externalId', externalId)
          ..add('kind', kind)
          ..add('name', name))
        .toString();
  }
}

class FinanceKitAccountBuilder
    implements Builder<FinanceKitAccount, FinanceKitAccountBuilder> {
  _$FinanceKitAccount? _$v;

  String? _balance;
  String? get balance => _$this._balance;
  set balance(String? balance) => _$this._balance = balance;

  FinanceKitAccountCreditDebitIndicatorEnum? _creditDebitIndicator;
  FinanceKitAccountCreditDebitIndicatorEnum? get creditDebitIndicator =>
      _$this._creditDebitIndicator;
  set creditDebitIndicator(
          FinanceKitAccountCreditDebitIndicatorEnum? creditDebitIndicator) =>
      _$this._creditDebitIndicator = creditDebitIndicator;

  String? _externalId;
  String? get externalId => _$this._externalId;
  set externalId(String? externalId) => _$this._externalId = externalId;

  FinanceKitAccountKindEnum? _kind;
  FinanceKitAccountKindEnum? get kind => _$this._kind;
  set kind(FinanceKitAccountKindEnum? kind) => _$this._kind = kind;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  FinanceKitAccountBuilder() {
    FinanceKitAccount._defaults(this);
  }

  FinanceKitAccountBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _balance = $v.balance;
      _creditDebitIndicator = $v.creditDebitIndicator;
      _externalId = $v.externalId;
      _kind = $v.kind;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FinanceKitAccount other) {
    _$v = other as _$FinanceKitAccount;
  }

  @override
  void update(void Function(FinanceKitAccountBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FinanceKitAccount build() => _build();

  _$FinanceKitAccount _build() {
    final _$result = _$v ??
        _$FinanceKitAccount._(
          balance: BuiltValueNullFieldError.checkNotNull(
              balance, r'FinanceKitAccount', 'balance'),
          creditDebitIndicator: BuiltValueNullFieldError.checkNotNull(
              creditDebitIndicator,
              r'FinanceKitAccount',
              'creditDebitIndicator'),
          externalId: BuiltValueNullFieldError.checkNotNull(
              externalId, r'FinanceKitAccount', 'externalId'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'FinanceKitAccount', 'kind'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'FinanceKitAccount', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
