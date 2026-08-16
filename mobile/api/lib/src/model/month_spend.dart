//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:spendable_api/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'month_spend.g.dart';

/// A month the user has spent in, for the month picker.
///
/// Properties:
/// * [month] 
/// * [spent] 
@BuiltValue()
abstract class MonthSpend implements Built<MonthSpend, MonthSpendBuilder> {
  @BuiltValueField(wireName: r'month')
  Date get month;

  @BuiltValueField(wireName: r'spent')
  String get spent;

  MonthSpend._();

  factory MonthSpend([void updates(MonthSpendBuilder b)]) = _$MonthSpend;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MonthSpendBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MonthSpend> get serializer => _$MonthSpendSerializer();
}

class _$MonthSpendSerializer implements PrimitiveSerializer<MonthSpend> {
  @override
  final Iterable<Type> types = const [MonthSpend, _$MonthSpend];

  @override
  final String wireName = r'MonthSpend';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MonthSpend object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'month';
    yield serializers.serialize(
      object.month,
      specifiedType: const FullType(Date),
    );
    yield r'spent';
    yield serializers.serialize(
      object.spent,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MonthSpend object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MonthSpendBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'month':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.month = valueDes;
          break;
        case r'spent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.spent = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MonthSpend deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MonthSpendBuilder();
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

