//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:spendable_api/src/model/bank_account.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'finance_kit_connection.g.dart';

/// The connection everything read out of Wallet belongs to.
///
/// Properties:
/// * [bankAccounts] 
/// * [historyToken] - Where the last read left off. Null means nothing has been read yet.
/// * [id] 
/// * [name] 
@BuiltValue()
abstract class FinanceKitConnection implements Built<FinanceKitConnection, FinanceKitConnectionBuilder> {
  @BuiltValueField(wireName: r'bank_accounts')
  BuiltList<BankAccount> get bankAccounts;

  /// Where the last read left off. Null means nothing has been read yet.
  @BuiltValueField(wireName: r'history_token')
  String? get historyToken;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  FinanceKitConnection._();

  factory FinanceKitConnection([void updates(FinanceKitConnectionBuilder b)]) = _$FinanceKitConnection;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FinanceKitConnectionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FinanceKitConnection> get serializer => _$FinanceKitConnectionSerializer();
}

class _$FinanceKitConnectionSerializer implements PrimitiveSerializer<FinanceKitConnection> {
  @override
  final Iterable<Type> types = const [FinanceKitConnection, _$FinanceKitConnection];

  @override
  final String wireName = r'FinanceKitConnection';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FinanceKitConnection object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'bank_accounts';
    yield serializers.serialize(
      object.bankAccounts,
      specifiedType: const FullType(BuiltList, [FullType(BankAccount)]),
    );
    if (object.historyToken != null) {
      yield r'history_token';
      yield serializers.serialize(
        object.historyToken,
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
  }

  @override
  Object serialize(
    Serializers serializers,
    FinanceKitConnection object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FinanceKitConnectionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'bank_accounts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BankAccount)]),
          ) as BuiltList<BankAccount>;
          result.bankAccounts.replace(valueDes);
          break;
        case r'history_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.historyToken = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FinanceKitConnection deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FinanceKitConnectionBuilder();
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

