//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bulk_failure.g.dart';

/// One transaction a bulk change did not apply to, and why.
///
/// Properties:
/// * [code] 
/// * [id] 
@BuiltValue()
abstract class BulkFailure implements Built<BulkFailure, BulkFailureBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'id')
  String get id;

  BulkFailure._();

  factory BulkFailure([void updates(BulkFailureBuilder b)]) = _$BulkFailure;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BulkFailureBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BulkFailure> get serializer => _$BulkFailureSerializer();
}

class _$BulkFailureSerializer implements PrimitiveSerializer<BulkFailure> {
  @override
  final Iterable<Type> types = const [BulkFailure, _$BulkFailure];

  @override
  final String wireName = r'BulkFailure';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BulkFailure object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
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
    BulkFailure object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BulkFailureBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
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
  BulkFailure deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BulkFailureBuilder();
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

