// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_summary.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BudgetSummary extends BudgetSummary {
  @override
  final String allocatedTotal;
  @override
  final BuiltList<Budget> budgets;
  @override
  final String creditCardBalance;
  @override
  final bool currentMonth;
  @override
  final String earnedTotal;
  @override
  final BuiltMap<String, String> funded;
  @override
  final String fundedTotal;
  @override
  final Date month;
  @override
  final BuiltMap<String, String> received;
  @override
  final String spendable;
  @override
  final BuiltMap<String, String> spent;
  @override
  final BuiltList<MonthSpend> spentByMonth;
  @override
  final String spentTotal;

  factory _$BudgetSummary([void Function(BudgetSummaryBuilder)? updates]) =>
      (BudgetSummaryBuilder()..update(updates))._build();

  _$BudgetSummary._(
      {required this.allocatedTotal,
      required this.budgets,
      required this.creditCardBalance,
      required this.currentMonth,
      required this.earnedTotal,
      required this.funded,
      required this.fundedTotal,
      required this.month,
      required this.received,
      required this.spendable,
      required this.spent,
      required this.spentByMonth,
      required this.spentTotal})
      : super._();
  @override
  BudgetSummary rebuild(void Function(BudgetSummaryBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BudgetSummaryBuilder toBuilder() => BudgetSummaryBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BudgetSummary &&
        allocatedTotal == other.allocatedTotal &&
        budgets == other.budgets &&
        creditCardBalance == other.creditCardBalance &&
        currentMonth == other.currentMonth &&
        earnedTotal == other.earnedTotal &&
        funded == other.funded &&
        fundedTotal == other.fundedTotal &&
        month == other.month &&
        received == other.received &&
        spendable == other.spendable &&
        spent == other.spent &&
        spentByMonth == other.spentByMonth &&
        spentTotal == other.spentTotal;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, allocatedTotal.hashCode);
    _$hash = $jc(_$hash, budgets.hashCode);
    _$hash = $jc(_$hash, creditCardBalance.hashCode);
    _$hash = $jc(_$hash, currentMonth.hashCode);
    _$hash = $jc(_$hash, earnedTotal.hashCode);
    _$hash = $jc(_$hash, funded.hashCode);
    _$hash = $jc(_$hash, fundedTotal.hashCode);
    _$hash = $jc(_$hash, month.hashCode);
    _$hash = $jc(_$hash, received.hashCode);
    _$hash = $jc(_$hash, spendable.hashCode);
    _$hash = $jc(_$hash, spent.hashCode);
    _$hash = $jc(_$hash, spentByMonth.hashCode);
    _$hash = $jc(_$hash, spentTotal.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BudgetSummary')
          ..add('allocatedTotal', allocatedTotal)
          ..add('budgets', budgets)
          ..add('creditCardBalance', creditCardBalance)
          ..add('currentMonth', currentMonth)
          ..add('earnedTotal', earnedTotal)
          ..add('funded', funded)
          ..add('fundedTotal', fundedTotal)
          ..add('month', month)
          ..add('received', received)
          ..add('spendable', spendable)
          ..add('spent', spent)
          ..add('spentByMonth', spentByMonth)
          ..add('spentTotal', spentTotal))
        .toString();
  }
}

class BudgetSummaryBuilder
    implements Builder<BudgetSummary, BudgetSummaryBuilder> {
  _$BudgetSummary? _$v;

  String? _allocatedTotal;
  String? get allocatedTotal => _$this._allocatedTotal;
  set allocatedTotal(String? allocatedTotal) =>
      _$this._allocatedTotal = allocatedTotal;

  ListBuilder<Budget>? _budgets;
  ListBuilder<Budget> get budgets => _$this._budgets ??= ListBuilder<Budget>();
  set budgets(ListBuilder<Budget>? budgets) => _$this._budgets = budgets;

  String? _creditCardBalance;
  String? get creditCardBalance => _$this._creditCardBalance;
  set creditCardBalance(String? creditCardBalance) =>
      _$this._creditCardBalance = creditCardBalance;

  bool? _currentMonth;
  bool? get currentMonth => _$this._currentMonth;
  set currentMonth(bool? currentMonth) => _$this._currentMonth = currentMonth;

  String? _earnedTotal;
  String? get earnedTotal => _$this._earnedTotal;
  set earnedTotal(String? earnedTotal) => _$this._earnedTotal = earnedTotal;

  MapBuilder<String, String>? _funded;
  MapBuilder<String, String> get funded =>
      _$this._funded ??= MapBuilder<String, String>();
  set funded(MapBuilder<String, String>? funded) => _$this._funded = funded;

  String? _fundedTotal;
  String? get fundedTotal => _$this._fundedTotal;
  set fundedTotal(String? fundedTotal) => _$this._fundedTotal = fundedTotal;

  Date? _month;
  Date? get month => _$this._month;
  set month(Date? month) => _$this._month = month;

  MapBuilder<String, String>? _received;
  MapBuilder<String, String> get received =>
      _$this._received ??= MapBuilder<String, String>();
  set received(MapBuilder<String, String>? received) =>
      _$this._received = received;

  String? _spendable;
  String? get spendable => _$this._spendable;
  set spendable(String? spendable) => _$this._spendable = spendable;

  MapBuilder<String, String>? _spent;
  MapBuilder<String, String> get spent =>
      _$this._spent ??= MapBuilder<String, String>();
  set spent(MapBuilder<String, String>? spent) => _$this._spent = spent;

  ListBuilder<MonthSpend>? _spentByMonth;
  ListBuilder<MonthSpend> get spentByMonth =>
      _$this._spentByMonth ??= ListBuilder<MonthSpend>();
  set spentByMonth(ListBuilder<MonthSpend>? spentByMonth) =>
      _$this._spentByMonth = spentByMonth;

  String? _spentTotal;
  String? get spentTotal => _$this._spentTotal;
  set spentTotal(String? spentTotal) => _$this._spentTotal = spentTotal;

  BudgetSummaryBuilder() {
    BudgetSummary._defaults(this);
  }

  BudgetSummaryBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _allocatedTotal = $v.allocatedTotal;
      _budgets = $v.budgets.toBuilder();
      _creditCardBalance = $v.creditCardBalance;
      _currentMonth = $v.currentMonth;
      _earnedTotal = $v.earnedTotal;
      _funded = $v.funded.toBuilder();
      _fundedTotal = $v.fundedTotal;
      _month = $v.month;
      _received = $v.received.toBuilder();
      _spendable = $v.spendable;
      _spent = $v.spent.toBuilder();
      _spentByMonth = $v.spentByMonth.toBuilder();
      _spentTotal = $v.spentTotal;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BudgetSummary other) {
    _$v = other as _$BudgetSummary;
  }

  @override
  void update(void Function(BudgetSummaryBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BudgetSummary build() => _build();

  _$BudgetSummary _build() {
    _$BudgetSummary _$result;
    try {
      _$result = _$v ??
          _$BudgetSummary._(
            allocatedTotal: BuiltValueNullFieldError.checkNotNull(
                allocatedTotal, r'BudgetSummary', 'allocatedTotal'),
            budgets: budgets.build(),
            creditCardBalance: BuiltValueNullFieldError.checkNotNull(
                creditCardBalance, r'BudgetSummary', 'creditCardBalance'),
            currentMonth: BuiltValueNullFieldError.checkNotNull(
                currentMonth, r'BudgetSummary', 'currentMonth'),
            earnedTotal: BuiltValueNullFieldError.checkNotNull(
                earnedTotal, r'BudgetSummary', 'earnedTotal'),
            funded: funded.build(),
            fundedTotal: BuiltValueNullFieldError.checkNotNull(
                fundedTotal, r'BudgetSummary', 'fundedTotal'),
            month: BuiltValueNullFieldError.checkNotNull(
                month, r'BudgetSummary', 'month'),
            received: received.build(),
            spendable: BuiltValueNullFieldError.checkNotNull(
                spendable, r'BudgetSummary', 'spendable'),
            spent: spent.build(),
            spentByMonth: spentByMonth.build(),
            spentTotal: BuiltValueNullFieldError.checkNotNull(
                spentTotal, r'BudgetSummary', 'spentTotal'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'budgets';
        budgets.build();

        _$failedField = 'funded';
        funded.build();

        _$failedField = 'received';
        received.build();

        _$failedField = 'spent';
        spent.build();
        _$failedField = 'spentByMonth';
        spentByMonth.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BudgetSummary', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
