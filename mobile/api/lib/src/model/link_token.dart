//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'link_token.g.dart';

/// Hand this to the Plaid Link SDK. Short-lived.
///
/// Properties:
/// * [linkToken] 
@BuiltValue()
abstract class LinkToken implements Built<LinkToken, LinkTokenBuilder> {
  @BuiltValueField(wireName: r'link_token')
  String get linkToken;

  LinkToken._();

  factory LinkToken([void updates(LinkTokenBuilder b)]) = _$LinkToken;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LinkTokenBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LinkToken> get serializer => _$LinkTokenSerializer();
}

class _$LinkTokenSerializer implements PrimitiveSerializer<LinkToken> {
  @override
  final Iterable<Type> types = const [LinkToken, _$LinkToken];

  @override
  final String wireName = r'LinkToken';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LinkToken object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'link_token';
    yield serializers.serialize(
      object.linkToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LinkToken object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LinkTokenBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'link_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.linkToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LinkToken deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LinkTokenBuilder();
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

