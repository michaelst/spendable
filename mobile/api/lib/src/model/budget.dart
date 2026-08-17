//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'budget.g.dart';

/// An envelope money is divided into. Amounts are decimal strings.
///
/// Properties:
/// * [archivedAt] 
/// * [balance] - What the fundings and allocations add up to, or the bank account's balance when assigned. 
/// * [budgetedAmount] 
/// * [fundingAmount] - What the budget puts into itself each month. Null means it does not fund itself.
/// * [id] 
/// * [name] 
/// * [rollover] - Whether the balance carries into next month. False means the month tops the budget back up to its funding amount instead, so an overspend does not follow it and leftover does not accumulate. Only an envelope can decline to roll over. 
/// * [type] 
@BuiltValue()
abstract class Budget implements Built<Budget, BudgetBuilder> {
  @BuiltValueField(wireName: r'archived_at')
  DateTime? get archivedAt;

  /// What the fundings and allocations add up to, or the bank account's balance when assigned. 
  @BuiltValueField(wireName: r'balance')
  String get balance;

  @BuiltValueField(wireName: r'budgeted_amount')
  String? get budgetedAmount;

  /// What the budget puts into itself each month. Null means it does not fund itself.
  @BuiltValueField(wireName: r'funding_amount')
  String? get fundingAmount;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  /// Whether the balance carries into next month. False means the month tops the budget back up to its funding amount instead, so an overspend does not follow it and leftover does not accumulate. Only an envelope can decline to roll over. 
  @BuiltValueField(wireName: r'rollover')
  bool get rollover;

  @BuiltValueField(wireName: r'type')
  BudgetTypeEnum get type;
  // enum typeEnum {  tracking,  envelope,  goal,  income,  };

  Budget._();

  factory Budget([void updates(BudgetBuilder b)]) = _$Budget;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BudgetBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Budget> get serializer => _$BudgetSerializer();
}

class _$BudgetSerializer implements PrimitiveSerializer<Budget> {
  @override
  final Iterable<Type> types = const [Budget, _$Budget];

  @override
  final String wireName = r'Budget';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Budget object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.archivedAt != null) {
      yield r'archived_at';
      yield serializers.serialize(
        object.archivedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    yield r'balance';
    yield serializers.serialize(
      object.balance,
      specifiedType: const FullType(String),
    );
    if (object.budgetedAmount != null) {
      yield r'budgeted_amount';
      yield serializers.serialize(
        object.budgetedAmount,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.fundingAmount != null) {
      yield r'funding_amount';
      yield serializers.serialize(
        object.fundingAmount,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'rollover';
    yield serializers.serialize(
      object.rollover,
      specifiedType: const FullType(bool),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(BudgetTypeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Budget object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BudgetBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'archived_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.archivedAt = valueDes;
          break;
        case r'balance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.balance = valueDes;
          break;
        case r'budgeted_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.budgetedAmount = valueDes;
          break;
        case r'funding_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.fundingAmount = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'rollover':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.rollover = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BudgetTypeEnum),
          ) as BudgetTypeEnum;
          result.type = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Budget deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BudgetBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class BudgetTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'tracking')
  static const BudgetTypeEnum tracking = _$budgetTypeEnum_tracking;
  @BuiltValueEnumConst(wireName: r'envelope')
  static const BudgetTypeEnum envelope = _$budgetTypeEnum_envelope;
  @BuiltValueEnumConst(wireName: r'goal')
  static const BudgetTypeEnum goal = _$budgetTypeEnum_goal;
  @BuiltValueEnumConst(wireName: r'income')
  static const BudgetTypeEnum income = _$budgetTypeEnum_income;

  static Serializer<BudgetTypeEnum> get serializer => _$budgetTypeEnumSerializer;

  const BudgetTypeEnum._(String name): super(name);

  static BuiltSet<BudgetTypeEnum> get values => _$budgetTypeEnumValues;
  static BudgetTypeEnum valueOf(String name) => _$budgetTypeEnumValueOf(name);
}

