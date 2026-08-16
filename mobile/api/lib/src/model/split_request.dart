//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:spendable_api/src/model/split_line_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'split_request.g.dart';

/// Send the whole set of lines you want the split to end up with. A line with an `id` is kept and updated, one without is added, and any line left out is deleted. 
///
/// Properties:
/// * [name] 
/// * [splitLines] 
@BuiltValue()
abstract class SplitRequest implements Built<SplitRequest, SplitRequestBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'split_lines')
  BuiltList<SplitLineRequest>? get splitLines;

  SplitRequest._();

  factory SplitRequest([void updates(SplitRequestBuilder b)]) = _$SplitRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SplitRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SplitRequest> get serializer => _$SplitRequestSerializer();
}

class _$SplitRequestSerializer implements PrimitiveSerializer<SplitRequest> {
  @override
  final Iterable<Type> types = const [SplitRequest, _$SplitRequest];

  @override
  final String wireName = r'SplitRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SplitRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.splitLines != null) {
      yield r'split_lines';
      yield serializers.serialize(
        object.splitLines,
        specifiedType: const FullType(BuiltList, [FullType(SplitLineRequest)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SplitRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SplitRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
            specifiedType: const FullType(BuiltList, [FullType(SplitLineRequest)]),
          ) as BuiltList<SplitLineRequest>;
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
  SplitRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SplitRequestBuilder();
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

