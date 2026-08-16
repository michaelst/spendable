//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:spendable_api/src/model/errors_errors_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'errors.g.dart';

/// The shape every failed request comes back in.
///
/// Properties:
/// * [errors] 
@BuiltValue()
abstract class Errors implements Built<Errors, ErrorsBuilder> {
  @BuiltValueField(wireName: r'errors')
  BuiltList<ErrorsErrorsInner> get errors;

  Errors._();

  factory Errors([void updates(ErrorsBuilder b)]) = _$Errors;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ErrorsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Errors> get serializer => _$ErrorsSerializer();
}

class _$ErrorsSerializer implements PrimitiveSerializer<Errors> {
  @override
  final Iterable<Type> types = const [Errors, _$Errors];

  @override
  final String wireName = r'Errors';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Errors object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'errors';
    yield serializers.serialize(
      object.errors,
      specifiedType: const FullType(BuiltList, [FullType(ErrorsErrorsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Errors object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ErrorsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'errors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ErrorsErrorsInner)]),
          ) as BuiltList<ErrorsErrorsInner>;
          result.errors.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Errors deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ErrorsBuilder();
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

