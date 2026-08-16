//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'session_update_request.g.dart';

/// The device this token was issued to, so the server can push to it.
///
/// Properties:
/// * [apnsToken] - The hex device token iOS handed the app.
@BuiltValue()
abstract class SessionUpdateRequest implements Built<SessionUpdateRequest, SessionUpdateRequestBuilder> {
  /// The hex device token iOS handed the app.
  @BuiltValueField(wireName: r'apns_token')
  String get apnsToken;

  SessionUpdateRequest._();

  factory SessionUpdateRequest([void updates(SessionUpdateRequestBuilder b)]) = _$SessionUpdateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SessionUpdateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SessionUpdateRequest> get serializer => _$SessionUpdateRequestSerializer();
}

class _$SessionUpdateRequestSerializer implements PrimitiveSerializer<SessionUpdateRequest> {
  @override
  final Iterable<Type> types = const [SessionUpdateRequest, _$SessionUpdateRequest];

  @override
  final String wireName = r'SessionUpdateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SessionUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'apns_token';
    yield serializers.serialize(
      object.apnsToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SessionUpdateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SessionUpdateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'apns_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.apnsToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SessionUpdateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SessionUpdateRequestBuilder();
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

