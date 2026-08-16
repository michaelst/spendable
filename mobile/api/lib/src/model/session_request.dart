//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'session_request.g.dart';

/// An ID token from a native sign-in, exchanged for an API token.
///
/// Properties:
/// * [deviceName] - Shown when managing signed-in devices.
/// * [idToken] 
/// * [provider] 
@BuiltValue()
abstract class SessionRequest implements Built<SessionRequest, SessionRequestBuilder> {
  /// Shown when managing signed-in devices.
  @BuiltValueField(wireName: r'device_name')
  String? get deviceName;

  @BuiltValueField(wireName: r'id_token')
  String get idToken;

  @BuiltValueField(wireName: r'provider')
  SessionRequestProviderEnum get provider;
  // enum providerEnum {  apple,  google,  };

  SessionRequest._();

  factory SessionRequest([void updates(SessionRequestBuilder b)]) = _$SessionRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SessionRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SessionRequest> get serializer => _$SessionRequestSerializer();
}

class _$SessionRequestSerializer implements PrimitiveSerializer<SessionRequest> {
  @override
  final Iterable<Type> types = const [SessionRequest, _$SessionRequest];

  @override
  final String wireName = r'SessionRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SessionRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.deviceName != null) {
      yield r'device_name';
      yield serializers.serialize(
        object.deviceName,
        specifiedType: const FullType(String),
      );
    }
    yield r'id_token';
    yield serializers.serialize(
      object.idToken,
      specifiedType: const FullType(String),
    );
    yield r'provider';
    yield serializers.serialize(
      object.provider,
      specifiedType: const FullType(SessionRequestProviderEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SessionRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SessionRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'device_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceName = valueDes;
          break;
        case r'id_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.idToken = valueDes;
          break;
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SessionRequestProviderEnum),
          ) as SessionRequestProviderEnum;
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
  SessionRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SessionRequestBuilder();
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

class SessionRequestProviderEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'apple')
  static const SessionRequestProviderEnum apple = _$sessionRequestProviderEnum_apple;
  @BuiltValueEnumConst(wireName: r'google')
  static const SessionRequestProviderEnum google = _$sessionRequestProviderEnum_google;

  static Serializer<SessionRequestProviderEnum> get serializer => _$sessionRequestProviderEnumSerializer;

  const SessionRequestProviderEnum._(String name): super(name);

  static BuiltSet<SessionRequestProviderEnum> get values => _$sessionRequestProviderEnumValues;
  static SessionRequestProviderEnum valueOf(String name) => _$sessionRequestProviderEnumValueOf(name);
}

