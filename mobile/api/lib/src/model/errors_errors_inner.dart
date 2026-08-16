//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:spendable_api/src/model/errors_errors_inner_source.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'errors_errors_inner.g.dart';

/// ErrorsErrorsInner
///
/// Properties:
/// * [code] - Machine-readable reason.
/// * [detail] 
/// * [source_] 
@BuiltValue()
abstract class ErrorsErrorsInner implements Built<ErrorsErrorsInner, ErrorsErrorsInnerBuilder> {
  /// Machine-readable reason.
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'detail')
  String get detail;

  @BuiltValueField(wireName: r'source')
  ErrorsErrorsInnerSource? get source_;

  ErrorsErrorsInner._();

  factory ErrorsErrorsInner([void updates(ErrorsErrorsInnerBuilder b)]) = _$ErrorsErrorsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ErrorsErrorsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ErrorsErrorsInner> get serializer => _$ErrorsErrorsInnerSerializer();
}

class _$ErrorsErrorsInnerSerializer implements PrimitiveSerializer<ErrorsErrorsInner> {
  @override
  final Iterable<Type> types = const [ErrorsErrorsInner, _$ErrorsErrorsInner];

  @override
  final String wireName = r'ErrorsErrorsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ErrorsErrorsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'detail';
    yield serializers.serialize(
      object.detail,
      specifiedType: const FullType(String),
    );
    if (object.source_ != null) {
      yield r'source';
      yield serializers.serialize(
        object.source_,
        specifiedType: const FullType(ErrorsErrorsInnerSource),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ErrorsErrorsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ErrorsErrorsInnerBuilder result,
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
        case r'detail':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.detail = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ErrorsErrorsInnerSource),
          ) as ErrorsErrorsInnerSource;
          result.source_.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ErrorsErrorsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ErrorsErrorsInnerBuilder();
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

