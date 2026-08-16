//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transaction_source.g.dart';

/// Where a synced transaction came from, flattened for the list row. Null on a transaction the user entered themselves. Fetch the logo from `/api/banks/{member_id}/logo`. 
///
/// Properties:
/// * [accountId] 
/// * [accountName] 
/// * [accountNumber] - Masked, last digits only.
/// * [memberHasLogo] 
/// * [memberId] 
/// * [memberName] 
/// * [pending] 
@BuiltValue()
abstract class TransactionSource implements Built<TransactionSource, TransactionSourceBuilder> {
  @BuiltValueField(wireName: r'account_id')
  String get accountId;

  @BuiltValueField(wireName: r'account_name')
  String get accountName;

  /// Masked, last digits only.
  @BuiltValueField(wireName: r'account_number')
  String? get accountNumber;

  @BuiltValueField(wireName: r'member_has_logo')
  bool get memberHasLogo;

  @BuiltValueField(wireName: r'member_id')
  String get memberId;

  @BuiltValueField(wireName: r'member_name')
  String get memberName;

  @BuiltValueField(wireName: r'pending')
  bool get pending;

  TransactionSource._();

  factory TransactionSource([void updates(TransactionSourceBuilder b)]) = _$TransactionSource;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TransactionSourceBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TransactionSource> get serializer => _$TransactionSourceSerializer();
}

class _$TransactionSourceSerializer implements PrimitiveSerializer<TransactionSource> {
  @override
  final Iterable<Type> types = const [TransactionSource, _$TransactionSource];

  @override
  final String wireName = r'TransactionSource';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TransactionSource object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'account_id';
    yield serializers.serialize(
      object.accountId,
      specifiedType: const FullType(String),
    );
    yield r'account_name';
    yield serializers.serialize(
      object.accountName,
      specifiedType: const FullType(String),
    );
    if (object.accountNumber != null) {
      yield r'account_number';
      yield serializers.serialize(
        object.accountNumber,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'member_has_logo';
    yield serializers.serialize(
      object.memberHasLogo,
      specifiedType: const FullType(bool),
    );
    yield r'member_id';
    yield serializers.serialize(
      object.memberId,
      specifiedType: const FullType(String),
    );
    yield r'member_name';
    yield serializers.serialize(
      object.memberName,
      specifiedType: const FullType(String),
    );
    yield r'pending';
    yield serializers.serialize(
      object.pending,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TransactionSource object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TransactionSourceBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'account_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accountId = valueDes;
          break;
        case r'account_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accountName = valueDes;
          break;
        case r'account_number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.accountNumber = valueDes;
          break;
        case r'member_has_logo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.memberHasLogo = valueDes;
          break;
        case r'member_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.memberId = valueDes;
          break;
        case r'member_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.memberName = valueDes;
          break;
        case r'pending':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.pending = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TransactionSource deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TransactionSourceBuilder();
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

