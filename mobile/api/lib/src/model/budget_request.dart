//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'budget_request.g.dart';

/// Amounts are decimal strings. `balance` is what the user wants the budget to hold - the server works out the adjustment that gets it there, so never send `adjustment`. 
///
/// Properties:
/// * [balance] 
/// * [budgetedAmount] 
/// * [name] 
/// * [type] 
@BuiltValue()
abstract class BudgetRequest implements Built<BudgetRequest, BudgetRequestBuilder> {
  @BuiltValueField(wireName: r'balance')
  String? get balance;

  @BuiltValueField(wireName: r'budgeted_amount')
  String? get budgetedAmount;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'type')
  BudgetRequestTypeEnum? get type;
  // enum typeEnum {  tracking,  envelope,  goal,  };

  BudgetRequest._();

  factory BudgetRequest([void updates(BudgetRequestBuilder b)]) = _$BudgetRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BudgetRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BudgetRequest> get serializer => _$BudgetRequestSerializer();
}

class _$BudgetRequestSerializer implements PrimitiveSerializer<BudgetRequest> {
  @override
  final Iterable<Type> types = const [BudgetRequest, _$BudgetRequest];

  @override
  final String wireName = r'BudgetRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BudgetRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.balance != null) {
      yield r'balance';
      yield serializers.serialize(
        object.balance,
        specifiedType: const FullType(String),
      );
    }
    if (object.budgetedAmount != null) {
      yield r'budgeted_amount';
      yield serializers.serialize(
        object.budgetedAmount,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(BudgetRequestTypeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BudgetRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BudgetRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BudgetRequestTypeEnum),
          ) as BudgetRequestTypeEnum;
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
  BudgetRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BudgetRequestBuilder();
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

class BudgetRequestTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'tracking')
  static const BudgetRequestTypeEnum tracking = _$budgetRequestTypeEnum_tracking;
  @BuiltValueEnumConst(wireName: r'envelope')
  static const BudgetRequestTypeEnum envelope = _$budgetRequestTypeEnum_envelope;
  @BuiltValueEnumConst(wireName: r'goal')
  static const BudgetRequestTypeEnum goal = _$budgetRequestTypeEnum_goal;

  static Serializer<BudgetRequestTypeEnum> get serializer => _$budgetRequestTypeEnumSerializer;

  const BudgetRequestTypeEnum._(String name): super(name);

  static BuiltSet<BudgetRequestTypeEnum> get values => _$budgetRequestTypeEnumValues;
  static BudgetRequestTypeEnum valueOf(String name) => _$budgetRequestTypeEnumValueOf(name);
}

