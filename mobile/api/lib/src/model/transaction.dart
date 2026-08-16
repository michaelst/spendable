//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:spendable_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:spendable_api/src/model/transaction_source.dart';
import 'package:spendable_api/src/model/budget_allocation.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transaction.g.dart';

/// A movement of money. Amounts are decimal strings, negative for money going out.  `budget_allocations` is what the server settled on, not what was sent: any part of the amount left unallocated lands on the Spendable budget on every write. Render what comes back. 
///
/// Properties:
/// * [amount] 
/// * [budgetAllocations] 
/// * [date] 
/// * [excluded] 
/// * [id] 
/// * [name] 
/// * [note] 
/// * [reviewed] 
/// * [source_] 
/// * [transferId] - The other side of a move between the user's own accounts.
@BuiltValue()
abstract class Transaction implements Built<Transaction, TransactionBuilder> {
  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'budget_allocations')
  BuiltList<BudgetAllocation> get budgetAllocations;

  @BuiltValueField(wireName: r'date')
  Date get date;

  @BuiltValueField(wireName: r'excluded')
  bool get excluded;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'reviewed')
  bool get reviewed;

  @BuiltValueField(wireName: r'source')
  TransactionSource? get source_;

  /// The other side of a move between the user's own accounts.
  @BuiltValueField(wireName: r'transfer_id')
  String? get transferId;

  Transaction._();

  factory Transaction([void updates(TransactionBuilder b)]) = _$Transaction;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TransactionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Transaction> get serializer => _$TransactionSerializer();
}

class _$TransactionSerializer implements PrimitiveSerializer<Transaction> {
  @override
  final Iterable<Type> types = const [Transaction, _$Transaction];

  @override
  final String wireName = r'Transaction';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Transaction object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'budget_allocations';
    yield serializers.serialize(
      object.budgetAllocations,
      specifiedType: const FullType(BuiltList, [FullType(BudgetAllocation)]),
    );
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(Date),
    );
    yield r'excluded';
    yield serializers.serialize(
      object.excluded,
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
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'reviewed';
    yield serializers.serialize(
      object.reviewed,
      specifiedType: const FullType(bool),
    );
    if (object.source_ != null) {
      yield r'source';
      yield serializers.serialize(
        object.source_,
        specifiedType: const FullType.nullable(TransactionSource),
      );
    }
    if (object.transferId != null) {
      yield r'transfer_id';
      yield serializers.serialize(
        object.transferId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Transaction object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TransactionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'budget_allocations':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BudgetAllocation)]),
          ) as BuiltList<BudgetAllocation>;
          result.budgetAllocations.replace(valueDes);
          break;
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.date = valueDes;
          break;
        case r'excluded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.excluded = valueDes;
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
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'reviewed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.reviewed = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(TransactionSource),
          ) as TransactionSource?;
          if (valueDes == null) continue;
          result.source_.replace(valueDes);
          break;
        case r'transfer_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.transferId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Transaction deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TransactionBuilder();
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

