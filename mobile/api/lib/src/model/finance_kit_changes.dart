//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:spendable_api/src/model/finance_kit_account.dart';
import 'package:spendable_api/src/model/finance_kit_charge.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'finance_kit_changes.g.dart';

/// One batch of what the device read out of Wallet. Send `history_token_before` as the token the last batch returned, or null on a full backfill; a mismatch is refused rather than applied. 
///
/// Properties:
/// * [accounts] 
/// * [deleted] - External ids of charges that were reversed or declined.
/// * [historyTokenAfter] 
/// * [historyTokenBefore] 
/// * [inserted] 
/// * [updated] - A charge keeps its id when it settles, so these are applied in place.
@BuiltValue()
abstract class FinanceKitChanges implements Built<FinanceKitChanges, FinanceKitChangesBuilder> {
  @BuiltValueField(wireName: r'accounts')
  BuiltList<FinanceKitAccount> get accounts;

  /// External ids of charges that were reversed or declined.
  @BuiltValueField(wireName: r'deleted')
  BuiltList<String>? get deleted;

  @BuiltValueField(wireName: r'history_token_after')
  String get historyTokenAfter;

  @BuiltValueField(wireName: r'history_token_before')
  String? get historyTokenBefore;

  @BuiltValueField(wireName: r'inserted')
  BuiltList<FinanceKitCharge>? get inserted;

  /// A charge keeps its id when it settles, so these are applied in place.
  @BuiltValueField(wireName: r'updated')
  BuiltList<FinanceKitCharge>? get updated;

  FinanceKitChanges._();

  factory FinanceKitChanges([void updates(FinanceKitChangesBuilder b)]) = _$FinanceKitChanges;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FinanceKitChangesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FinanceKitChanges> get serializer => _$FinanceKitChangesSerializer();
}

class _$FinanceKitChangesSerializer implements PrimitiveSerializer<FinanceKitChanges> {
  @override
  final Iterable<Type> types = const [FinanceKitChanges, _$FinanceKitChanges];

  @override
  final String wireName = r'FinanceKitChanges';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FinanceKitChanges object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'accounts';
    yield serializers.serialize(
      object.accounts,
      specifiedType: const FullType(BuiltList, [FullType(FinanceKitAccount)]),
    );
    if (object.deleted != null) {
      yield r'deleted';
      yield serializers.serialize(
        object.deleted,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    yield r'history_token_after';
    yield serializers.serialize(
      object.historyTokenAfter,
      specifiedType: const FullType(String),
    );
    if (object.historyTokenBefore != null) {
      yield r'history_token_before';
      yield serializers.serialize(
        object.historyTokenBefore,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.inserted != null) {
      yield r'inserted';
      yield serializers.serialize(
        object.inserted,
        specifiedType: const FullType(BuiltList, [FullType(FinanceKitCharge)]),
      );
    }
    if (object.updated != null) {
      yield r'updated';
      yield serializers.serialize(
        object.updated,
        specifiedType: const FullType(BuiltList, [FullType(FinanceKitCharge)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    FinanceKitChanges object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FinanceKitChangesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accounts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(FinanceKitAccount)]),
          ) as BuiltList<FinanceKitAccount>;
          result.accounts.replace(valueDes);
          break;
        case r'deleted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.deleted.replace(valueDes);
          break;
        case r'history_token_after':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.historyTokenAfter = valueDes;
          break;
        case r'history_token_before':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.historyTokenBefore = valueDes;
          break;
        case r'inserted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(FinanceKitCharge)]),
          ) as BuiltList<FinanceKitCharge>;
          result.inserted.replace(valueDes);
          break;
        case r'updated':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(FinanceKitCharge)]),
          ) as BuiltList<FinanceKitCharge>;
          result.updated.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FinanceKitChanges deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FinanceKitChangesBuilder();
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

