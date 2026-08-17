//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:spendable_api/src/model/date.dart';
import 'package:built_collection/built_collection.dart';
import 'package:spendable_api/src/model/budget.dart';
import 'package:spendable_api/src/model/month_spend.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'budget_summary.g.dart';

/// Everything the budgets screen shows for one month. Presentation is the client's - this is the numbers behind it. 
///
/// Properties:
/// * [allocatedTotal] - Budgeted across envelopes.
/// * [budgets] 
/// * [creditCardBalance] 
/// * [currentMonth] - Spendable, allocated and credit cards only apply to the current month.
/// * [earnedTotal] - Taken in across income budgets this month.
/// * [funded] - Funded this month, keyed by budget id. Every listed budget has an entry.
/// * [fundedTotal] - Put into envelopes this month.
/// * [month] 
/// * [received] - Taken in this month, keyed by budget id. Only an income budget receives; every other budget is zero here, and money arriving in one of those is a refund counted against its spending instead. 
/// * [spendable] - Synced money no budget has claimed.
/// * [spent] - Spent this month, keyed by budget id. Every listed budget has an entry.
/// * [spentByMonth] - Newest first, for the month picker.
/// * [spentTotal] - Spent across envelopes this month.
@BuiltValue()
abstract class BudgetSummary implements Built<BudgetSummary, BudgetSummaryBuilder> {
  /// Budgeted across envelopes.
  @BuiltValueField(wireName: r'allocated_total')
  String get allocatedTotal;

  @BuiltValueField(wireName: r'budgets')
  BuiltList<Budget> get budgets;

  @BuiltValueField(wireName: r'credit_card_balance')
  String get creditCardBalance;

  /// Spendable, allocated and credit cards only apply to the current month.
  @BuiltValueField(wireName: r'current_month')
  bool get currentMonth;

  /// Taken in across income budgets this month.
  @BuiltValueField(wireName: r'earned_total')
  String get earnedTotal;

  /// Funded this month, keyed by budget id. Every listed budget has an entry.
  @BuiltValueField(wireName: r'funded')
  BuiltMap<String, String> get funded;

  /// Put into envelopes this month.
  @BuiltValueField(wireName: r'funded_total')
  String get fundedTotal;

  @BuiltValueField(wireName: r'month')
  Date get month;

  /// Taken in this month, keyed by budget id. Only an income budget receives; every other budget is zero here, and money arriving in one of those is a refund counted against its spending instead. 
  @BuiltValueField(wireName: r'received')
  BuiltMap<String, String> get received;

  /// Synced money no budget has claimed.
  @BuiltValueField(wireName: r'spendable')
  String get spendable;

  /// Spent this month, keyed by budget id. Every listed budget has an entry.
  @BuiltValueField(wireName: r'spent')
  BuiltMap<String, String> get spent;

  /// Newest first, for the month picker.
  @BuiltValueField(wireName: r'spent_by_month')
  BuiltList<MonthSpend> get spentByMonth;

  /// Spent across envelopes this month.
  @BuiltValueField(wireName: r'spent_total')
  String get spentTotal;

  BudgetSummary._();

  factory BudgetSummary([void updates(BudgetSummaryBuilder b)]) = _$BudgetSummary;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BudgetSummaryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BudgetSummary> get serializer => _$BudgetSummarySerializer();
}

class _$BudgetSummarySerializer implements PrimitiveSerializer<BudgetSummary> {
  @override
  final Iterable<Type> types = const [BudgetSummary, _$BudgetSummary];

  @override
  final String wireName = r'BudgetSummary';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BudgetSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'allocated_total';
    yield serializers.serialize(
      object.allocatedTotal,
      specifiedType: const FullType(String),
    );
    yield r'budgets';
    yield serializers.serialize(
      object.budgets,
      specifiedType: const FullType(BuiltList, [FullType(Budget)]),
    );
    yield r'credit_card_balance';
    yield serializers.serialize(
      object.creditCardBalance,
      specifiedType: const FullType(String),
    );
    yield r'current_month';
    yield serializers.serialize(
      object.currentMonth,
      specifiedType: const FullType(bool),
    );
    yield r'earned_total';
    yield serializers.serialize(
      object.earnedTotal,
      specifiedType: const FullType(String),
    );
    yield r'funded';
    yield serializers.serialize(
      object.funded,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
    yield r'funded_total';
    yield serializers.serialize(
      object.fundedTotal,
      specifiedType: const FullType(String),
    );
    yield r'month';
    yield serializers.serialize(
      object.month,
      specifiedType: const FullType(Date),
    );
    yield r'received';
    yield serializers.serialize(
      object.received,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
    yield r'spendable';
    yield serializers.serialize(
      object.spendable,
      specifiedType: const FullType(String),
    );
    yield r'spent';
    yield serializers.serialize(
      object.spent,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
    yield r'spent_by_month';
    yield serializers.serialize(
      object.spentByMonth,
      specifiedType: const FullType(BuiltList, [FullType(MonthSpend)]),
    );
    yield r'spent_total';
    yield serializers.serialize(
      object.spentTotal,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BudgetSummary object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BudgetSummaryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'allocated_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.allocatedTotal = valueDes;
          break;
        case r'budgets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Budget)]),
          ) as BuiltList<Budget>;
          result.budgets.replace(valueDes);
          break;
        case r'credit_card_balance':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.creditCardBalance = valueDes;
          break;
        case r'current_month':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.currentMonth = valueDes;
          break;
        case r'earned_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.earnedTotal = valueDes;
          break;
        case r'funded':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.funded.replace(valueDes);
          break;
        case r'funded_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fundedTotal = valueDes;
          break;
        case r'month':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.month = valueDes;
          break;
        case r'received':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.received.replace(valueDes);
          break;
        case r'spendable':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.spendable = valueDes;
          break;
        case r'spent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.spent.replace(valueDes);
          break;
        case r'spent_by_month':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MonthSpend)]),
          ) as BuiltList<MonthSpend>;
          result.spentByMonth.replace(valueDes);
          break;
        case r'spent_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.spentTotal = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BudgetSummary deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BudgetSummaryBuilder();
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

