//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'errors_errors_inner_source.g.dart';

/// Present on validation errors, pointing at the offending field.
///
/// Properties:
/// * [pointer] 
@BuiltValue()
abstract class ErrorsErrorsInnerSource implements Built<ErrorsErrorsInnerSource, ErrorsErrorsInnerSourceBuilder> {
  @BuiltValueField(wireName: r'pointer')
  String? get pointer;

  ErrorsErrorsInnerSource._();

  factory ErrorsErrorsInnerSource([void updates(ErrorsErrorsInnerSourceBuilder b)]) = _$ErrorsErrorsInnerSource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ErrorsErrorsInnerSourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ErrorsErrorsInnerSource> get serializer => _$ErrorsErrorsInnerSourceSerializer();
}

class _$ErrorsErrorsInnerSourceSerializer implements PrimitiveSerializer<ErrorsErrorsInnerSource> {
  @override
  final Iterable<Type> types = const [ErrorsErrorsInnerSource, _$ErrorsErrorsInnerSource];

  @override
  final String wireName = r'ErrorsErrorsInnerSource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ErrorsErrorsInnerSource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.pointer != null) {
      yield r'pointer';
      yield serializers.serialize(
        object.pointer,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ErrorsErrorsInnerSource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ErrorsErrorsInnerSourceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pointer':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pointer = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ErrorsErrorsInnerSource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ErrorsErrorsInnerSourceBuilder();
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

