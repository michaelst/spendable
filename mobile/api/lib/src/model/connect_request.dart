//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'connect_request.g.dart';

/// The public token Plaid Link returns once the user has picked a bank.
///
/// Properties:
/// * [publicToken] 
@BuiltValue()
abstract class ConnectRequest implements Built<ConnectRequest, ConnectRequestBuilder> {
  @BuiltValueField(wireName: r'public_token')
  String get publicToken;

  ConnectRequest._();

  factory ConnectRequest([void updates(ConnectRequestBuilder b)]) = _$ConnectRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConnectRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConnectRequest> get serializer => _$ConnectRequestSerializer();
}

class _$ConnectRequestSerializer implements PrimitiveSerializer<ConnectRequest> {
  @override
  final Iterable<Type> types = const [ConnectRequest, _$ConnectRequest];

  @override
  final String wireName = r'ConnectRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConnectRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'public_token';
    yield serializers.serialize(
      object.publicToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConnectRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConnectRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'public_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.publicToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConnectRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConnectRequestBuilder();
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

