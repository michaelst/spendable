// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BudgetRequestTypeEnum _$budgetRequestTypeEnum_tracking =
    const BudgetRequestTypeEnum._('tracking');
const BudgetRequestTypeEnum _$budgetRequestTypeEnum_envelope =
    const BudgetRequestTypeEnum._('envelope');
const BudgetRequestTypeEnum _$budgetRequestTypeEnum_goal =
    const BudgetRequestTypeEnum._('goal');

BudgetRequestTypeEnum _$budgetRequestTypeEnumValueOf(String name) {
  switch (name) {
    case 'tracking':
      return _$budgetRequestTypeEnum_tracking;
    case 'envelope':
      return _$budgetRequestTypeEnum_envelope;
    case 'goal':
      return _$budgetRequestTypeEnum_goal;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BudgetRequestTypeEnum> _$budgetRequestTypeEnumValues =
    BuiltSet<BudgetRequestTypeEnum>(const <BudgetRequestTypeEnum>[
  _$budgetRequestTypeEnum_tracking,
  _$budgetRequestTypeEnum_envelope,
  _$budgetRequestTypeEnum_goal,
]);

Serializer<BudgetRequestTypeEnum> _$budgetRequestTypeEnumSerializer =
    _$BudgetRequestTypeEnumSerializer();

class _$BudgetRequestTypeEnumSerializer
    implements PrimitiveSerializer<BudgetRequestTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'tracking': 'tracking',
    'envelope': 'envelope',
    'goal': 'goal',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'tracking': 'tracking',
    'envelope': 'envelope',
    'goal': 'goal',
  };

  @override
  final Iterable<Type> types = const <Type>[BudgetRequestTypeEnum];
  @override
  final String wireName = 'BudgetRequestTypeEnum';

  @override
  Object serialize(Serializers serializers, BudgetRequestTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BudgetRequestTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BudgetRequestTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$BudgetRequest extends BudgetRequest {
  @override
  final String? balance;
  @override
  final String? budgetedAmount;
  @override
  final String? name;
  @override
  final BudgetRequestTypeEnum? type;

  factory _$BudgetRequest([void Function(BudgetRequestBuilder)? updates]) =>
      (BudgetRequestBuilder()..update(updates))._build();

  _$BudgetRequest._({this.balance, this.budgetedAmount, this.name, this.type})
      : super._();
  @override
  BudgetRequest rebuild(void Function(BudgetRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BudgetRequestBuilder toBuilder() => BudgetRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BudgetRequest &&
        balance == other.balance &&
        budgetedAmount == other.budgetedAmount &&
        name == other.name &&
        type == other.type;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, balance.hashCode);
    _$hash = $jc(_$hash, budgetedAmount.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BudgetRequest')
          ..add('balance', balance)
          ..add('budgetedAmount', budgetedAmount)
          ..add('name', name)
          ..add('type', type))
        .toString();
  }
}

class BudgetRequestBuilder
    implements Builder<BudgetRequest, BudgetRequestBuilder> {
  _$BudgetRequest? _$v;

  String? _balance;
  String? get balance => _$this._balance;
  set balance(String? balance) => _$this._balance = balance;

  String? _budgetedAmount;
  String? get budgetedAmount => _$this._budgetedAmount;
  set budgetedAmount(String? budgetedAmount) =>
      _$this._budgetedAmount = budgetedAmount;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  BudgetRequestTypeEnum? _type;
  BudgetRequestTypeEnum? get type => _$this._type;
  set type(BudgetRequestTypeEnum? type) => _$this._type = type;

  BudgetRequestBuilder() {
    BudgetRequest._defaults(this);
  }

  BudgetRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _balance = $v.balance;
      _budgetedAmount = $v.budgetedAmount;
      _name = $v.name;
      _type = $v.type;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BudgetRequest other) {
    _$v = other as _$BudgetRequest;
  }

  @override
  void update(void Function(BudgetRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BudgetRequest build() => _build();

  _$BudgetRequest _build() {
    final _$result = _$v ??
        _$BudgetRequest._(
          balance: balance,
          budgetedAmount: budgetedAmount,
          name: name,
          type: type,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
