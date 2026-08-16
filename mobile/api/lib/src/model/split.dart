//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:spendable_api/src/model/split_line.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'split.g.dart';

/// A saved division of a transaction across budgets. Amounts are decimal strings.
///
/// Properties:
/// * [archivedAt] 
/// * [id] 
/// * [name] 
/// * [splitLines] - Oldest first.
@BuiltValue()
abstract class Split implements Built<Split, SplitBuilder> {
  @BuiltValueField(wireName: r'archived_at')
  DateTime? get archivedAt;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  /// Oldest first.
  @BuiltValueField(wireName: r'split_lines')
  BuiltList<SplitLine> get splitLines;

  Split._();

  factory Split([void updates(SplitBuilder b)]) = _$Split;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SplitBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Split> get serializer => _$SplitSerializer();
}

class _$SplitSerializer implements PrimitiveSerializer<Split> {
  @override
  final Iterable<Type> types = const [Split, _$Split];

  @override
  final String wireName = r'Split';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Split object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.archivedAt != null) {
      yield r'archived_at';
      yield serializers.serialize(
        object.archivedAt,
        specifiedType: const FullType.nullable(DateTime),
      );
    }
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'split_lines';
    yield serializers.serialize(
      object.splitLines,
      specifiedType: const FullType(BuiltList, [FullType(SplitLine)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Split object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SplitBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'archived_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.archivedAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'split_lines':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(SplitLine)]),
          ) as BuiltList<SplitLine>;
          result.splitLines.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Split deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SplitBuilder();
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

