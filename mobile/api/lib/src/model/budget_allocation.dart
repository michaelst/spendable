//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'budget_allocation.g.dart';

/// One budget's share of a transaction.
///
/// Properties:
/// * [amount] 
/// * [budgetId] 
/// * [id] 
@BuiltValue()
abstract class BudgetAllocation implements Built<BudgetAllocation, BudgetAllocationBuilder> {
  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'budget_id')
  String get budgetId;

  @BuiltValueField(wireName: r'id')
  String get id;

  BudgetAllocation._();

  factory BudgetAllocation([void updates(BudgetAllocationBuilder b)]) = _$BudgetAllocation;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BudgetAllocationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BudgetAllocation> get serializer => _$BudgetAllocationSerializer();
}

class _$BudgetAllocationSerializer implements PrimitiveSerializer<BudgetAllocation> {
  @override
  final Iterable<Type> types = const [BudgetAllocation, _$BudgetAllocation];

  @override
  final String wireName = r'BudgetAllocation';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BudgetAllocation object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'budget_id';
    yield serializers.serialize(
      object.budgetId,
      specifiedType: const FullType(String),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BudgetAllocation object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BudgetAllocationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'budget_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.budgetId = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BudgetAllocation deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BudgetAllocationBuilder();
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

