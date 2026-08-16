//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:spendable_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:spendable_api/src/model/budget_allocation_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transaction_request.g.dart';

/// Send the whole set of allocations you want. One with an `id` is kept and updated, one without is added, one left out is deleted. Whatever is left of the amount goes to Spendable, so the allocations in the response are the ones that count.  That also means a validation error's pointer indexes the list the server settled on, not the one that was sent - match the offending line by its `budget_id`, not by position. 
///
/// Properties:
/// * [amount] - Negative for money going out.
/// * [budgetAllocations] 
/// * [date] 
/// * [excluded] 
/// * [name] 
/// * [note] 
/// * [reviewed] 
@BuiltValue()
abstract class TransactionRequest implements Built<TransactionRequest, TransactionRequestBuilder> {
  /// Negative for money going out.
  @BuiltValueField(wireName: r'amount')
  String? get amount;

  @BuiltValueField(wireName: r'budget_allocations')
  BuiltList<BudgetAllocationRequest>? get budgetAllocations;

  @BuiltValueField(wireName: r'date')
  Date? get date;

  @BuiltValueField(wireName: r'excluded')
  bool? get excluded;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'reviewed')
  bool? get reviewed;

  TransactionRequest._();

  factory TransactionRequest([void updates(TransactionRequestBuilder b)]) = _$TransactionRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TransactionRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TransactionRequest> get serializer => _$TransactionRequestSerializer();
}

class _$TransactionRequestSerializer implements PrimitiveSerializer<TransactionRequest> {
  @override
  final Iterable<Type> types = const [TransactionRequest, _$TransactionRequest];

  @override
  final String wireName = r'TransactionRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TransactionRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.amount != null) {
      yield r'amount';
      yield serializers.serialize(
        object.amount,
        specifiedType: const FullType(String),
      );
    }
    if (object.budgetAllocations != null) {
      yield r'budget_allocations';
      yield serializers.serialize(
        object.budgetAllocations,
        specifiedType: const FullType(BuiltList, [FullType(BudgetAllocationRequest)]),
      );
    }
    if (object.date != null) {
      yield r'date';
      yield serializers.serialize(
        object.date,
        specifiedType: const FullType(Date),
      );
    }
    if (object.excluded != null) {
      yield r'excluded';
      yield serializers.serialize(
        object.excluded,
        specifiedType: const FullType(bool),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.reviewed != null) {
      yield r'reviewed';
      yield serializers.serialize(
        object.reviewed,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    TransactionRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TransactionRequestBuilder result,
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
        case r'budget_allocations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BudgetAllocationRequest)]),
          ) as BuiltList<BudgetAllocationRequest>;
          result.budgetAllocations.replace(valueDes);
          break;
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.date = valueDes;
          break;
        case r'excluded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.excluded = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'reviewed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.reviewed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TransactionRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TransactionRequestBuilder();
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

