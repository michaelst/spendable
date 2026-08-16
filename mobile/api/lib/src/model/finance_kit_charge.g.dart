// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_kit_charge.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FinanceKitChargeCreditDebitIndicatorEnum
    _$financeKitChargeCreditDebitIndicatorEnum_credit =
    const FinanceKitChargeCreditDebitIndicatorEnum._('credit');
const FinanceKitChargeCreditDebitIndicatorEnum
    _$financeKitChargeCreditDebitIndicatorEnum_debit =
    const FinanceKitChargeCreditDebitIndicatorEnum._('debit');

FinanceKitChargeCreditDebitIndicatorEnum
    _$financeKitChargeCreditDebitIndicatorEnumValueOf(String name) {
  switch (name) {
    case 'credit':
      return _$financeKitChargeCreditDebitIndicatorEnum_credit;
    case 'debit':
      return _$financeKitChargeCreditDebitIndicatorEnum_debit;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<FinanceKitChargeCreditDebitIndicatorEnum>
    _$financeKitChargeCreditDebitIndicatorEnumValues = BuiltSet<
        FinanceKitChargeCreditDebitIndicatorEnum>(const <FinanceKitChargeCreditDebitIndicatorEnum>[
  _$financeKitChargeCreditDebitIndicatorEnum_credit,
  _$financeKitChargeCreditDebitIndicatorEnum_debit,
]);

Serializer<FinanceKitChargeCreditDebitIndicatorEnum>
    _$financeKitChargeCreditDebitIndicatorEnumSerializer =
    _$FinanceKitChargeCreditDebitIndicatorEnumSerializer();

class _$FinanceKitChargeCreditDebitIndicatorEnumSerializer
    implements PrimitiveSerializer<FinanceKitChargeCreditDebitIndicatorEnum> {
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
    FinanceKitChargeCreditDebitIndicatorEnum
  ];
  @override
  final String wireName = 'FinanceKitChargeCreditDebitIndicatorEnum';

  @override
  Object serialize(Serializers serializers,
          FinanceKitChargeCreditDebitIndicatorEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  FinanceKitChargeCreditDebitIndicatorEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      FinanceKitChargeCreditDebitIndicatorEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$FinanceKitCharge extends FinanceKitCharge {
  @override
  final String accountExternalId;
  @override
  final String amount;
  @override
  final FinanceKitChargeCreditDebitIndicatorEnum creditDebitIndicator;
  @override
  final Date date;
  @override
  final String externalId;
  @override
  final String name;
  @override
  final bool pending;

  factory _$FinanceKitCharge(
          [void Function(FinanceKitChargeBuilder)? updates]) =>
      (FinanceKitChargeBuilder()..update(updates))._build();

  _$FinanceKitCharge._(
      {required this.accountExternalId,
      required this.amount,
      required this.creditDebitIndicator,
      required this.date,
      required this.externalId,
      required this.name,
      required this.pending})
      : super._();
  @override
  FinanceKitCharge rebuild(void Function(FinanceKitChargeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FinanceKitChargeBuilder toBuilder() =>
      FinanceKitChargeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FinanceKitCharge &&
        accountExternalId == other.accountExternalId &&
        amount == other.amount &&
        creditDebitIndicator == other.creditDebitIndicator &&
        date == other.date &&
        externalId == other.externalId &&
        name == other.name &&
        pending == other.pending;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accountExternalId.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, creditDebitIndicator.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, externalId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, pending.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FinanceKitCharge')
          ..add('accountExternalId', accountExternalId)
          ..add('amount', amount)
          ..add('creditDebitIndicator', creditDebitIndicator)
          ..add('date', date)
          ..add('externalId', externalId)
          ..add('name', name)
          ..add('pending', pending))
        .toString();
  }
}

class FinanceKitChargeBuilder
    implements Builder<FinanceKitCharge, FinanceKitChargeBuilder> {
  _$FinanceKitCharge? _$v;

  String? _accountExternalId;
  String? get accountExternalId => _$this._accountExternalId;
  set accountExternalId(String? accountExternalId) =>
      _$this._accountExternalId = accountExternalId;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  FinanceKitChargeCreditDebitIndicatorEnum? _creditDebitIndicator;
  FinanceKitChargeCreditDebitIndicatorEnum? get creditDebitIndicator =>
      _$this._creditDebitIndicator;
  set creditDebitIndicator(
          FinanceKitChargeCreditDebitIndicatorEnum? creditDebitIndicator) =>
      _$this._creditDebitIndicator = creditDebitIndicator;

  Date? _date;
  Date? get date => _$this._date;
  set date(Date? date) => _$this._date = date;

  String? _externalId;
  String? get externalId => _$this._externalId;
  set externalId(String? externalId) => _$this._externalId = externalId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  bool? _pending;
  bool? get pending => _$this._pending;
  set pending(bool? pending) => _$this._pending = pending;

  FinanceKitChargeBuilder() {
    FinanceKitCharge._defaults(this);
  }

  FinanceKitChargeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accountExternalId = $v.accountExternalId;
      _amount = $v.amount;
      _creditDebitIndicator = $v.creditDebitIndicator;
      _date = $v.date;
      _externalId = $v.externalId;
      _name = $v.name;
      _pending = $v.pending;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FinanceKitCharge other) {
    _$v = other as _$FinanceKitCharge;
  }

  @override
  void update(void Function(FinanceKitChargeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FinanceKitCharge build() => _build();

  _$FinanceKitCharge _build() {
    final _$result = _$v ??
        _$FinanceKitCharge._(
          accountExternalId: BuiltValueNullFieldError.checkNotNull(
              accountExternalId, r'FinanceKitCharge', 'accountExternalId'),
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'FinanceKitCharge', 'amount'),
          creditDebitIndicator: BuiltValueNullFieldError.checkNotNull(
              creditDebitIndicator,
              r'FinanceKitCharge',
              'creditDebitIndicator'),
          date: BuiltValueNullFieldError.checkNotNull(
              date, r'FinanceKitCharge', 'date'),
          externalId: BuiltValueNullFieldError.checkNotNull(
              externalId, r'FinanceKitCharge', 'externalId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'FinanceKitCharge', 'name'),
          pending: BuiltValueNullFieldError.checkNotNull(
              pending, r'FinanceKitCharge', 'pending'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
