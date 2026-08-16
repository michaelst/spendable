//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:spendable_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'finance_kit_charge.g.dart';

/// One charge exactly as Wallet reported it.
///
/// Properties:
/// * [accountExternalId] 
/// * [amount] - Unsigned. The indicator decides the sign.
/// * [creditDebitIndicator] - Which way the money went. Debits are stored negative.
/// * [date] 
/// * [externalId] 
/// * [name] 
/// * [pending] 
@BuiltValue()
abstract class FinanceKitCharge implements Built<FinanceKitCharge, FinanceKitChargeBuilder> {
  @BuiltValueField(wireName: r'account_external_id')
  String get accountExternalId;

  /// Unsigned. The indicator decides the sign.
  @BuiltValueField(wireName: r'amount')
  String get amount;

  /// Which way the money went. Debits are stored negative.
  @BuiltValueField(wireName: r'credit_debit_indicator')
  FinanceKitChargeCreditDebitIndicatorEnum get creditDebitIndicator;
  // enum creditDebitIndicatorEnum {  credit,  debit,  };

  @BuiltValueField(wireName: r'date')
  Date get date;

  @BuiltValueField(wireName: r'external_id')
  String get externalId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'pending')
  bool get pending;

  FinanceKitCharge._();

  factory FinanceKitCharge([void updates(FinanceKitChargeBuilder b)]) = _$FinanceKitCharge;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FinanceKitChargeBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FinanceKitCharge> get serializer => _$FinanceKitChargeSerializer();
}

class _$FinanceKitChargeSerializer implements PrimitiveSerializer<FinanceKitCharge> {
  @override
  final Iterable<Type> types = const [FinanceKitCharge, _$FinanceKitCharge];

  @override
  final String wireName = r'FinanceKitCharge';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FinanceKitCharge object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'account_external_id';
    yield serializers.serialize(
      object.accountExternalId,
      specifiedType: const FullType(String),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'credit_debit_indicator';
    yield serializers.serialize(
      object.creditDebitIndicator,
      specifiedType: const FullType(FinanceKitChargeCreditDebitIndicatorEnum),
    );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(Date),
    );
    yield r'external_id';
    yield serializers.serialize(
      object.externalId,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
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
    FinanceKitCharge object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FinanceKitChargeBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'account_external_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accountExternalId = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'credit_debit_indicator':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FinanceKitChargeCreditDebitIndicatorEnum),
          ) as FinanceKitChargeCreditDebitIndicatorEnum;
          result.creditDebitIndicator = valueDes;
          break;
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.date = valueDes;
          break;
        case r'external_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.externalId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
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
  FinanceKitCharge deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FinanceKitChargeBuilder();
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

class FinanceKitChargeCreditDebitIndicatorEnum extends EnumClass {

  /// Which way the money went. Debits are stored negative.
  @BuiltValueEnumConst(wireName: r'credit')
  static const FinanceKitChargeCreditDebitIndicatorEnum credit = _$financeKitChargeCreditDebitIndicatorEnum_credit;
  /// Which way the money went. Debits are stored negative.
  @BuiltValueEnumConst(wireName: r'debit')
  static const FinanceKitChargeCreditDebitIndicatorEnum debit = _$financeKitChargeCreditDebitIndicatorEnum_debit;

  static Serializer<FinanceKitChargeCreditDebitIndicatorEnum> get serializer => _$financeKitChargeCreditDebitIndicatorEnumSerializer;

  const FinanceKitChargeCreditDebitIndicatorEnum._(String name): super(name);

  static BuiltSet<FinanceKitChargeCreditDebitIndicatorEnum> get values => _$financeKitChargeCreditDebitIndicatorEnumValues;
  static FinanceKitChargeCreditDebitIndicatorEnum valueOf(String name) => _$financeKitChargeCreditDebitIndicatorEnumValueOf(name);
}

