//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:spendable_api/src/model/bulk_failure.dart';
import 'package:spendable_api/src/model/transaction.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bulk_result.g.dart';

/// A bulk change is applied per transaction rather than all or nothing, so the ones that worked come back alongside the ones that did not. 
///
/// Properties:
/// * [failed] 
/// * [transactions] 
@BuiltValue()
abstract class BulkResult implements Built<BulkResult, BulkResultBuilder> {
  @BuiltValueField(wireName: r'failed')
  BuiltList<BulkFailure> get failed;

  @BuiltValueField(wireName: r'transactions')
  BuiltList<Transaction> get transactions;

  BulkResult._();

  factory BulkResult([void updates(BulkResultBuilder b)]) = _$BulkResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BulkResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BulkResult> get serializer => _$BulkResultSerializer();
}

class _$BulkResultSerializer implements PrimitiveSerializer<BulkResult> {
  @override
  final Iterable<Type> types = const [BulkResult, _$BulkResult];

  @override
  final String wireName = r'BulkResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BulkResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'failed';
    yield serializers.serialize(
      object.failed,
      specifiedType: const FullType(BuiltList, [FullType(BulkFailure)]),
    );
    yield r'transactions';
    yield serializers.serialize(
      object.transactions,
      specifiedType: const FullType(BuiltList, [FullType(Transaction)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BulkResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BulkResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'failed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BulkFailure)]),
          ) as BuiltList<BulkFailure>;
          result.failed.replace(valueDes);
          break;
        case r'transactions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Transaction)]),
          ) as BuiltList<Transaction>;
          result.transactions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BulkResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BulkResultBuilder();
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

