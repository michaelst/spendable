//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:spendable_api/src/model/bank_account.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'bank_member.g.dart';

/// A connection to an institution, and the accounts inside it.
///
/// Properties:
/// * [bankAccounts] 
/// * [hasLogo] - Fetch it from `/api/banks/{id}/logo` when true.
/// * [id] 
/// * [name] 
/// * [provider] - Who supplies the connection.
/// * [status] - Anything other than \"CONNECTED\" means the user has to reconnect.
@BuiltValue()
abstract class BankMember implements Built<BankMember, BankMemberBuilder> {
  @BuiltValueField(wireName: r'bank_accounts')
  BuiltList<BankAccount> get bankAccounts;

  /// Fetch it from `/api/banks/{id}/logo` when true.
  @BuiltValueField(wireName: r'has_logo')
  bool get hasLogo;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  /// Who supplies the connection.
  @BuiltValueField(wireName: r'provider')
  String get provider;

  /// Anything other than \"CONNECTED\" means the user has to reconnect.
  @BuiltValueField(wireName: r'status')
  String? get status;

  BankMember._();

  factory BankMember([void updates(BankMemberBuilder b)]) = _$BankMember;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BankMemberBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BankMember> get serializer => _$BankMemberSerializer();
}

class _$BankMemberSerializer implements PrimitiveSerializer<BankMember> {
  @override
  final Iterable<Type> types = const [BankMember, _$BankMember];

  @override
  final String wireName = r'BankMember';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BankMember object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'bank_accounts';
    yield serializers.serialize(
      object.bankAccounts,
      specifiedType: const FullType(BuiltList, [FullType(BankAccount)]),
    );
    yield r'has_logo';
    yield serializers.serialize(
      object.hasLogo,
      specifiedType: const FullType(bool),
    );
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
    yield r'provider';
    yield serializers.serialize(
      object.provider,
      specifiedType: const FullType(String),
    );
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BankMember object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BankMemberBuilder result,
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
        case r'has_logo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasLogo = valueDes;
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
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.provider = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.status = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BankMember deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BankMemberBuilder();
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

