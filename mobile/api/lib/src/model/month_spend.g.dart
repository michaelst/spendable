// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_spend.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MonthSpend extends MonthSpend {
  @override
  final Date month;
  @override
  final String spent;

  factory _$MonthSpend([void Function(MonthSpendBuilder)? updates]) =>
      (MonthSpendBuilder()..update(updates))._build();

  _$MonthSpend._({required this.month, required this.spent}) : super._();
  @override
  MonthSpend rebuild(void Function(MonthSpendBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MonthSpendBuilder toBuilder() => MonthSpendBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MonthSpend && month == other.month && spent == other.spent;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, month.hashCode);
    _$hash = $jc(_$hash, spent.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MonthSpend')
          ..add('month', month)
          ..add('spent', spent))
        .toString();
  }
}

class MonthSpendBuilder implements Builder<MonthSpend, MonthSpendBuilder> {
  _$MonthSpend? _$v;

  Date? _month;
  Date? get month => _$this._month;
  set month(Date? month) => _$this._month = month;

  String? _spent;
  String? get spent => _$this._spent;
  set spent(String? spent) => _$this._spent = spent;

  MonthSpendBuilder() {
    MonthSpend._defaults(this);
  }

  MonthSpendBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _month = $v.month;
      _spent = $v.spent;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MonthSpend other) {
    _$v = other as _$MonthSpend;
  }

  @override
  void update(void Function(MonthSpendBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MonthSpend build() => _build();

  _$MonthSpend _build() {
    final _$result = _$v ??
        _$MonthSpend._(
          month: BuiltValueNullFieldError.checkNotNull(
              month, r'MonthSpend', 'month'),
          spent: BuiltValueNullFieldError.checkNotNull(
              spent, r'MonthSpend', 'spent'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
