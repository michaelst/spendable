//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bulk_request.g.dart';

/// Applies the same change to several transactions. `budget_id` spends each transaction's whole amount from that budget, replacing whatever it was allocated to before. 
///
/// Properties:
/// * [budgetId] 
/// * [excluded] 
/// * [reviewed] 
/// * [transactionIds] 
@BuiltValue()
abstract class BulkRequest implements Built<BulkRequest, BulkRequestBuilder> {
  @BuiltValueField(wireName: r'budget_id')
  String? get budgetId;

  @BuiltValueField(wireName: r'excluded')
  bool? get excluded;

  @BuiltValueField(wireName: r'reviewed')
  bool? get reviewed;

  @BuiltValueField(wireName: r'transaction_ids')
  BuiltList<String> get transactionIds;

  BulkRequest._();

  factory BulkRequest([void updates(BulkRequestBuilder b)]) = _$BulkRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BulkRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BulkRequest> get serializer => _$BulkRequestSerializer();
}

class _$BulkRequestSerializer implements PrimitiveSerializer<BulkRequest> {
  @override
  final Iterable<Type> types = const [BulkRequest, _$BulkRequest];

  @override
  final String wireName = r'BulkRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BulkRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.budgetId != null) {
      yield r'budget_id';
      yield serializers.serialize(
        object.budgetId,
        specifiedType: const FullType(String),
      );
    }
    if (object.excluded != null) {
      yield r'excluded';
      yield serializers.serialize(
        object.excluded,
        specifiedType: const FullType(bool),
      );
    }
    if (object.reviewed != null) {
      yield r'reviewed';
      yield serializers.serialize(
        object.reviewed,
        specifiedType: const FullType(bool),
      );
    }
    yield r'transaction_ids';
    yield serializers.serialize(
      object.transactionIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BulkRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BulkRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'budget_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.budgetId = valueDes;
          break;
        case r'excluded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.excluded = valueDes;
          break;
        case r'reviewed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.reviewed = valueDes;
          break;
        case r'transaction_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.transactionIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BulkRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BulkRequestBuilder();
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

