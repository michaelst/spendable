// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_kit_result.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FinanceKitResult extends FinanceKitResult {
  @override
  final int applied;
  @override
  final String historyToken;

  factory _$FinanceKitResult(
          [void Function(FinanceKitResultBuilder)? updates]) =>
      (FinanceKitResultBuilder()..update(updates))._build();

  _$FinanceKitResult._({required this.applied, required this.historyToken})
      : super._();
  @override
  FinanceKitResult rebuild(void Function(FinanceKitResultBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FinanceKitResultBuilder toBuilder() =>
      FinanceKitResultBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FinanceKitResult &&
        applied == other.applied &&
        historyToken == other.historyToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, applied.hashCode);
    _$hash = $jc(_$hash, historyToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FinanceKitResult')
          ..add('applied', applied)
          ..add('historyToken', historyToken))
        .toString();
  }
}

class FinanceKitResultBuilder
    implements Builder<FinanceKitResult, FinanceKitResultBuilder> {
  _$FinanceKitResult? _$v;

  int? _applied;
  int? get applied => _$this._applied;
  set applied(int? applied) => _$this._applied = applied;

  String? _historyToken;
  String? get historyToken => _$this._historyToken;
  set historyToken(String? historyToken) => _$this._historyToken = historyToken;

  FinanceKitResultBuilder() {
    FinanceKitResult._defaults(this);
  }

  FinanceKitResultBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _applied = $v.applied;
      _historyToken = $v.historyToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FinanceKitResult other) {
    _$v = other as _$FinanceKitResult;
  }

  @override
  void update(void Function(FinanceKitResultBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FinanceKitResult build() => _build();

  _$FinanceKitResult _build() {
    final _$result = _$v ??
        _$FinanceKitResult._(
          applied: BuiltValueNullFieldError.checkNotNull(
              applied, r'FinanceKitResult', 'applied'),
          historyToken: BuiltValueNullFieldError.checkNotNull(
              historyToken, r'FinanceKitResult', 'historyToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
