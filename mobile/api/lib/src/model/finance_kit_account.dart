//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'finance_kit_account.g.dart';

/// One account in the user's Wallet. The kind is mapped onto the vocabulary the rest of the API already uses, so an Apple Card reads as a credit card and Apple Cash as a checking account. 
///
/// Properties:
/// * [balance] - Unsigned. The indicator decides the sign.
/// * [creditDebitIndicator] - A card's balance is a debit, because it is owed.
/// * [externalId] 
/// * [kind] 
/// * [name] 
@BuiltValue()
abstract class FinanceKitAccount implements Built<FinanceKitAccount, FinanceKitAccountBuilder> {
  /// Unsigned. The indicator decides the sign.
  @BuiltValueField(wireName: r'balance')
  String get balance;

  /// A card's balance is a debit, because it is owed.
  @BuiltValueField(wireName: r'credit_debit_indicator')
  FinanceKitAccountCreditDebitIndicatorEnum get creditDebitIndicator;
  // enum creditDebitIndicatorEnum {  credit,  debit,  };

  @BuiltValueField(wireName: r'external_id')
  String get externalId;

  @BuiltValueField(wireName: r'kind')
  FinanceKitAccountKindEnum get kind;
  // enum kindEnum {  credit_card,  cash,  savings,  };

  @BuiltValueField(wireName: r'name')
  String get name;

  FinanceKitAccount._();

  factory FinanceKitAccount([void updates(FinanceKitAccountBuilder b)]) = _$FinanceKitAccount;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FinanceKitAccountBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FinanceKitAccount> get serializer => _$FinanceKitAccountSerializer();
}

class _$FinanceKitAccountSerializer implements PrimitiveSerializer<FinanceKitAccount> {
  @override
  final Iterable<Type> types = const [FinanceKitAccount, _$FinanceKitAccount];

  @override
  final String wireName = r'FinanceKitAccount';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FinanceKitAccount object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'balance';
    yield serializers.serialize(
      object.balance,
      specifiedType: const FullType(String),
    );
    yield r'credit_debit_indicator';
    yield serializers.serialize(
      object.creditDebitIndicator,
      specifiedType: const FullType(FinanceKitAccountCreditDebitIndicatorEnum),
    );
    yield r'external_id';
    yield serializers.serialize(
      object.externalId,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(FinanceKitAccountKindEnum),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FinanceKitAccount object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FinanceKitAccountBuilder result,
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
        case r'credit_debit_indicator':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FinanceKitAccountCreditDebitIndicatorEnum),
          ) as FinanceKitAccountCreditDebitIndicatorEnum;
          result.creditDebitIndicator = valueDes;
          break;
        case r'external_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.externalId = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FinanceKitAccountKindEnum),
          ) as FinanceKitAccountKindEnum;
          result.kind = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FinanceKitAccount deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FinanceKitAccountBuilder();
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

class FinanceKitAccountCreditDebitIndicatorEnum extends EnumClass {

  /// A card's balance is a debit, because it is owed.
  @BuiltValueEnumConst(wireName: r'credit')
  static const FinanceKitAccountCreditDebitIndicatorEnum credit = _$financeKitAccountCreditDebitIndicatorEnum_credit;
  /// A card's balance is a debit, because it is owed.
  @BuiltValueEnumConst(wireName: r'debit')
  static const FinanceKitAccountCreditDebitIndicatorEnum debit = _$financeKitAccountCreditDebitIndicatorEnum_debit;

  static Serializer<FinanceKitAccountCreditDebitIndicatorEnum> get serializer => _$financeKitAccountCreditDebitIndicatorEnumSerializer;

  const FinanceKitAccountCreditDebitIndicatorEnum._(String name): super(name);

  static BuiltSet<FinanceKitAccountCreditDebitIndicatorEnum> get values => _$financeKitAccountCreditDebitIndicatorEnumValues;
  static FinanceKitAccountCreditDebitIndicatorEnum valueOf(String name) => _$financeKitAccountCreditDebitIndicatorEnumValueOf(name);
}

class FinanceKitAccountKindEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'credit_card')
  static const FinanceKitAccountKindEnum creditCard = _$financeKitAccountKindEnum_creditCard;
  @BuiltValueEnumConst(wireName: r'cash')
  static const FinanceKitAccountKindEnum cash = _$financeKitAccountKindEnum_cash;
  @BuiltValueEnumConst(wireName: r'savings')
  static const FinanceKitAccountKindEnum savings = _$financeKitAccountKindEnum_savings;

  static Serializer<FinanceKitAccountKindEnum> get serializer => _$financeKitAccountKindEnumSerializer;

  const FinanceKitAccountKindEnum._(String name): super(name);

  static BuiltSet<FinanceKitAccountKindEnum> get values => _$financeKitAccountKindEnumValues;
  static FinanceKitAccountKindEnum valueOf(String name) => _$financeKitAccountKindEnumValueOf(name);
}

