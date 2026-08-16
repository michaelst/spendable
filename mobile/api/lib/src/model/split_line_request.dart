//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'split_line_request.g.dart';

/// A line to keep, update or add. Distinct from SplitLine because `id` is optional.
///
/// Properties:
/// * [amount] 
/// * [budgetId] 
/// * [id] - Omit to add a new line.
@BuiltValue()
abstract class SplitLineRequest implements Built<SplitLineRequest, SplitLineRequestBuilder> {
  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'budget_id')
  String get budgetId;

  /// Omit to add a new line.
  @BuiltValueField(wireName: r'id')
  String? get id;

  SplitLineRequest._();

  factory SplitLineRequest([void updates(SplitLineRequestBuilder b)]) = _$SplitLineRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SplitLineRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SplitLineRequest> get serializer => _$SplitLineRequestSerializer();
}

class _$SplitLineRequestSerializer implements PrimitiveSerializer<SplitLineRequest> {
  @override
  final Iterable<Type> types = const [SplitLineRequest, _$SplitLineRequest];

  @override
  final String wireName = r'SplitLineRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SplitLineRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'budget_id';
    yield serializers.serialize(
      object.budgetId,
      specifiedType: const FullType(String),
    );
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SplitLineRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SplitLineRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'budget_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.budgetId = valueDes;
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
  SplitLineRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SplitLineRequestBuilder();
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

