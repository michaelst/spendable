//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'budget_allocation_request.g.dart';

/// An allocation to keep, update or add. Distinct from BudgetAllocation because `id` is optional. 
///
/// Properties:
/// * [amount] 
/// * [budgetId] 
/// * [id] - Omit to add a new allocation.
@BuiltValue()
abstract class BudgetAllocationRequest implements Built<BudgetAllocationRequest, BudgetAllocationRequestBuilder> {
  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'budget_id')
  String get budgetId;

  /// Omit to add a new allocation.
  @BuiltValueField(wireName: r'id')
  String? get id;

  BudgetAllocationRequest._();

  factory BudgetAllocationRequest([void updates(BudgetAllocationRequestBuilder b)]) = _$BudgetAllocationRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BudgetAllocationRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BudgetAllocationRequest> get serializer => _$BudgetAllocationRequestSerializer();
}

class _$BudgetAllocationRequestSerializer implements PrimitiveSerializer<BudgetAllocationRequest> {
  @override
  final Iterable<Type> types = const [BudgetAllocationRequest, _$BudgetAllocationRequest];

  @override
  final String wireName = r'BudgetAllocationRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BudgetAllocationRequest object, {
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
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BudgetAllocationRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BudgetAllocationRequestBuilder result,
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
  BudgetAllocationRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BudgetAllocationRequestBuilder();
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

