//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bank_account.g.dart';

/// An account inside a connection. Amounts are decimal strings.
///
/// Properties:
/// * [balance] - Negative on a credit card, as a ledger reads.
/// * [budgetId] - When set, this account's balance is that budget's balance.
/// * [id] 
/// * [name] 
/// * [number] - Masked, last digits only.
/// * [subType] 
/// * [sync_] - Whether activity is pulled and counted.
/// * [type] 
@BuiltValue()
abstract class BankAccount implements Built<BankAccount, BankAccountBuilder> {
  /// Negative on a credit card, as a ledger reads.
  @BuiltValueField(wireName: r'balance')
  String get balance;

  /// When set, this account's balance is that budget's balance.
  @BuiltValueField(wireName: r'budget_id')
  String? get budgetId;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  /// Masked, last digits only.
  @BuiltValueField(wireName: r'number')
  String? get number;

  @BuiltValueField(wireName: r'sub_type')
  String get subType;

  /// Whether activity is pulled and counted.
  @BuiltValueField(wireName: r'sync')
  bool get sync_;

  @BuiltValueField(wireName: r'type')
  String get type;

  BankAccount._();

  factory BankAccount([void updates(BankAccountBuilder b)]) = _$BankAccount;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BankAccountBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BankAccount> get serializer => _$BankAccountSerializer();
}

class _$BankAccountSerializer implements PrimitiveSerializer<BankAccount> {
  @override
  final Iterable<Type> types = const [BankAccount, _$BankAccount];

  @override
  final String wireName = r'BankAccount';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BankAccount object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'balance';
    yield serializers.serialize(
      object.balance,
      specifiedType: const FullType(String),
    );
    if (object.budgetId != null) {
      yield r'budget_id';
      yield serializers.serialize(
        object.budgetId,
        specifiedType: const FullType.nullable(String),
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
    if (object.number != null) {
      yield r'number';
      yield serializers.serialize(
        object.number,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'sub_type';
    yield serializers.serialize(
      object.subType,
      specifiedType: const FullType(String),
    );
    yield r'sync';
    yield serializers.serialize(
      object.sync_,
      specifiedType: const FullType(bool),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BankAccount object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BankAccountBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'balance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.balance = valueDes;
          break;
        case r'budget_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.budgetId = valueDes;
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
        case r'number':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.number = valueDes;
          break;
        case r'sub_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.subType = valueDes;
          break;
        case r'sync':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.sync_ = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BankAccount deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BankAccountBuilder();
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

