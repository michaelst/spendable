// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const BudgetTypeEnum _$budgetTypeEnum_tracking =
    const BudgetTypeEnum._('tracking');
const BudgetTypeEnum _$budgetTypeEnum_envelope =
    const BudgetTypeEnum._('envelope');
const BudgetTypeEnum _$budgetTypeEnum_goal = const BudgetTypeEnum._('goal');
const BudgetTypeEnum _$budgetTypeEnum_income = const BudgetTypeEnum._('income');

BudgetTypeEnum _$budgetTypeEnumValueOf(String name) {
  switch (name) {
    case 'tracking':
      return _$budgetTypeEnum_tracking;
    case 'envelope':
      return _$budgetTypeEnum_envelope;
    case 'goal':
      return _$budgetTypeEnum_goal;
    case 'income':
      return _$budgetTypeEnum_income;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<BudgetTypeEnum> _$budgetTypeEnumValues =
    BuiltSet<BudgetTypeEnum>(const <BudgetTypeEnum>[
  _$budgetTypeEnum_tracking,
  _$budgetTypeEnum_envelope,
  _$budgetTypeEnum_goal,
  _$budgetTypeEnum_income,
]);

Serializer<BudgetTypeEnum> _$budgetTypeEnumSerializer =
    _$BudgetTypeEnumSerializer();

class _$BudgetTypeEnumSerializer
    implements PrimitiveSerializer<BudgetTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'tracking': 'tracking',
    'envelope': 'envelope',
    'goal': 'goal',
    'income': 'income',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'tracking': 'tracking',
    'envelope': 'envelope',
    'goal': 'goal',
    'income': 'income',
  };

  @override
  final Iterable<Type> types = const <Type>[BudgetTypeEnum];
  @override
  final String wireName = 'BudgetTypeEnum';

  @override
  Object serialize(Serializers serializers, BudgetTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  BudgetTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      BudgetTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Budget extends Budget {
  @override
  final DateTime? archivedAt;
  @override
  final String balance;
  @override
  final String? budgetedAmount;
  @override
  final String? fundingAmount;
  @override
  final String id;
  @override
  final String name;
  @override
  final bool rollover;
  @override
  final BudgetTypeEnum type;

  factory _$Budget([void Function(BudgetBuilder)? updates]) =>
      (BudgetBuilder()..update(updates))._build();

  _$Budget._(
      {this.archivedAt,
      required this.balance,
      this.budgetedAmount,
      this.fundingAmount,
      required this.id,
      required this.name,
      required this.rollover,
      required this.type})
      : super._();
  @override
  Budget rebuild(void Function(BudgetBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BudgetBuilder toBuilder() => BudgetBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Budget &&
        archivedAt == other.archivedAt &&
        balance == other.balance &&
        budgetedAmount == other.budgetedAmount &&
        fundingAmount == other.fundingAmount &&
        id == other.id &&
        name == other.name &&
        rollover == other.rollover &&
        type == other.type;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, archivedAt.hashCode);
    _$hash = $jc(_$hash, balance.hashCode);
    _$hash = $jc(_$hash, budgetedAmount.hashCode);
    _$hash = $jc(_$hash, fundingAmount.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, rollover.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Budget')
          ..add('archivedAt', archivedAt)
          ..add('balance', balance)
          ..add('budgetedAmount', budgetedAmount)
          ..add('fundingAmount', fundingAmount)
          ..add('id', id)
          ..add('name', name)
          ..add('rollover', rollover)
          ..add('type', type))
        .toString();
  }
}

class BudgetBuilder implements Builder<Budget, BudgetBuilder> {
  _$Budget? _$v;

  DateTime? _archivedAt;
  DateTime? get archivedAt => _$this._archivedAt;
  set archivedAt(DateTime? archivedAt) => _$this._archivedAt = archivedAt;

  String? _balance;
  String? get balance => _$this._balance;
  set balance(String? balance) => _$this._balance = balance;

  String? _budgetedAmount;
  String? get budgetedAmount => _$this._budgetedAmount;
  set budgetedAmount(String? budgetedAmount) =>
      _$this._budgetedAmount = budgetedAmount;

  String? _fundingAmount;
  String? get fundingAmount => _$this._fundingAmount;
  set fundingAmount(String? fundingAmount) =>
      _$this._fundingAmount = fundingAmount;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  bool? _rollover;
  bool? get rollover => _$this._rollover;
  set rollover(bool? rollover) => _$this._rollover = rollover;

  BudgetTypeEnum? _type;
  BudgetTypeEnum? get type => _$this._type;
  set type(BudgetTypeEnum? type) => _$this._type = type;

  BudgetBuilder() {
    Budget._defaults(this);
  }

  BudgetBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _archivedAt = $v.archivedAt;
      _balance = $v.balance;
      _budgetedAmount = $v.budgetedAmount;
      _fundingAmount = $v.fundingAmount;
      _id = $v.id;
      _name = $v.name;
      _rollover = $v.rollover;
      _type = $v.type;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Budget other) {
    _$v = other as _$Budget;
  }

  @override
  void update(void Function(BudgetBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Budget build() => _build();

  _$Budget _build() {
    final _$result = _$v ??
        _$Budget._(
          archivedAt: archivedAt,
          balance: BuiltValueNullFieldError.checkNotNull(
              balance, r'Budget', 'balance'),
          budgetedAmount: budgetedAmount,
          fundingAmount: fundingAmount,
          id: BuiltValueNullFieldError.checkNotNull(id, r'Budget', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(name, r'Budget', 'name'),
          rollover: BuiltValueNullFieldError.checkNotNull(
              rollover, r'Budget', 'rollover'),
          type: BuiltValueNullFieldError.checkNotNull(type, r'Budget', 'type'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
