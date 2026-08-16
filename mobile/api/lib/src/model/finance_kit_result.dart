//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'finance_kit_result.g.dart';

/// What a batch changed, and where to resume from.
///
/// Properties:
/// * [applied] - Rows changed. Lower than what was sent when a batch is replayed.
/// * [historyToken] 
@BuiltValue()
abstract class FinanceKitResult implements Built<FinanceKitResult, FinanceKitResultBuilder> {
  /// Rows changed. Lower than what was sent when a batch is replayed.
  @BuiltValueField(wireName: r'applied')
  int get applied;

  @BuiltValueField(wireName: r'history_token')
  String get historyToken;

  FinanceKitResult._();

  factory FinanceKitResult([void updates(FinanceKitResultBuilder b)]) = _$FinanceKitResult;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FinanceKitResultBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FinanceKitResult> get serializer => _$FinanceKitResultSerializer();
}

class _$FinanceKitResultSerializer implements PrimitiveSerializer<FinanceKitResult> {
  @override
  final Iterable<Type> types = const [FinanceKitResult, _$FinanceKitResult];

  @override
  final String wireName = r'FinanceKitResult';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FinanceKitResult object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'applied';
    yield serializers.serialize(
      object.applied,
      specifiedType: const FullType(int),
    );
    yield r'history_token';
    yield serializers.serialize(
      object.historyToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FinanceKitResult object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FinanceKitResultBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'applied':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.applied = valueDes;
          break;
        case r'history_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.historyToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FinanceKitResult deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FinanceKitResultBuilder();
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

