//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'identity.g.dart';

/// A way of signing into an account.
///
/// Properties:
/// * [id] 
/// * [provider] 
@BuiltValue()
abstract class Identity implements Built<Identity, IdentityBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'provider')
  IdentityProviderEnum get provider;
  // enum providerEnum {  apple,  google,  };

  Identity._();

  factory Identity([void updates(IdentityBuilder b)]) = _$Identity;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(IdentityBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Identity> get serializer => _$IdentitySerializer();
}

class _$IdentitySerializer implements PrimitiveSerializer<Identity> {
  @override
  final Iterable<Type> types = const [Identity, _$Identity];

  @override
  final String wireName = r'Identity';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Identity object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'provider';
    yield serializers.serialize(
      object.provider,
      specifiedType: const FullType(IdentityProviderEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Identity object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required IdentityBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(IdentityProviderEnum),
          ) as IdentityProviderEnum;
          result.provider = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Identity deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = IdentityBuilder();
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

class IdentityProviderEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'apple')
  static const IdentityProviderEnum apple = _$identityProviderEnum_apple;
  @BuiltValueEnumConst(wireName: r'google')
  static const IdentityProviderEnum google = _$identityProviderEnum_google;

  static Serializer<IdentityProviderEnum> get serializer => _$identityProviderEnumSerializer;

  const IdentityProviderEnum._(String name): super(name);

  static BuiltSet<IdentityProviderEnum> get values => _$identityProviderEnumValues;
  static IdentityProviderEnum valueOf(String name) => _$identityProviderEnumValueOf(name);
}

