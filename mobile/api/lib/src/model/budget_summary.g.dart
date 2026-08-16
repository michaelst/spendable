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
  final Date month;
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
      required this.month,
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
        month == other.month &&
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
    _$hash = $jc(_$hash, month.hashCode);
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
          ..add('month', month)
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

  Date? _month;
  Date? get month => _$this._month;
  set month(Date? month) => _$this._month = month;

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
      _month = $v.month;
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
            month: BuiltValueNullFieldError.checkNotNull(
                month, r'BudgetSummary', 'month'),
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
