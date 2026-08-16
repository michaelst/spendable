//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bank_account_request.g.dart';

/// The two things a user decides about an account: whether to sync it, and where it belongs.
///
/// Properties:
/// * [budgetId] - Null unassigns, putting the balance back into Spendable.
/// * [sync_] 
@BuiltValue()
abstract class BankAccountRequest implements Built<BankAccountRequest, BankAccountRequestBuilder> {
  /// Null unassigns, putting the balance back into Spendable.
  @BuiltValueField(wireName: r'budget_id')
  String? get budgetId;

  @BuiltValueField(wireName: r'sync')
  bool? get sync_;

  BankAccountRequest._();

  factory BankAccountRequest([void updates(BankAccountRequestBuilder b)]) = _$BankAccountRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BankAccountRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BankAccountRequest> get serializer => _$BankAccountRequestSerializer();
}

class _$BankAccountRequestSerializer implements PrimitiveSerializer<BankAccountRequest> {
  @override
  final Iterable<Type> types = const [BankAccountRequest, _$BankAccountRequest];

  @override
  final String wireName = r'BankAccountRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BankAccountRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.budgetId != null) {
      yield r'budget_id';
      yield serializers.serialize(
        object.budgetId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.sync_ != null) {
      yield r'sync';
      yield serializers.serialize(
        object.sync_,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BankAccountRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BankAccountRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'budget_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.budgetId = valueDes;
          break;
        case r'sync':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.sync_ = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BankAccountRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BankAccountRequestBuilder();
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

