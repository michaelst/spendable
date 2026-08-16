// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_kit_changes.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FinanceKitChanges extends FinanceKitChanges {
  @override
  final BuiltList<FinanceKitAccount> accounts;
  @override
  final BuiltList<String>? deleted;
  @override
  final String historyTokenAfter;
  @override
  final String? historyTokenBefore;
  @override
  final BuiltList<FinanceKitCharge>? inserted;
  @override
  final BuiltList<FinanceKitCharge>? updated;

  factory _$FinanceKitChanges(
          [void Function(FinanceKitChangesBuilder)? updates]) =>
      (FinanceKitChangesBuilder()..update(updates))._build();

  _$FinanceKitChanges._(
      {required this.accounts,
      this.deleted,
      required this.historyTokenAfter,
      this.historyTokenBefore,
      this.inserted,
      this.updated})
      : super._();
  @override
  FinanceKitChanges rebuild(void Function(FinanceKitChangesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FinanceKitChangesBuilder toBuilder() =>
      FinanceKitChangesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FinanceKitChanges &&
        accounts == other.accounts &&
        deleted == other.deleted &&
        historyTokenAfter == other.historyTokenAfter &&
        historyTokenBefore == other.historyTokenBefore &&
        inserted == other.inserted &&
        updated == other.updated;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, accounts.hashCode);
    _$hash = $jc(_$hash, deleted.hashCode);
    _$hash = $jc(_$hash, historyTokenAfter.hashCode);
    _$hash = $jc(_$hash, historyTokenBefore.hashCode);
    _$hash = $jc(_$hash, inserted.hashCode);
    _$hash = $jc(_$hash, updated.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FinanceKitChanges')
          ..add('accounts', accounts)
          ..add('deleted', deleted)
          ..add('historyTokenAfter', historyTokenAfter)
          ..add('historyTokenBefore', historyTokenBefore)
          ..add('inserted', inserted)
          ..add('updated', updated))
        .toString();
  }
}

class FinanceKitChangesBuilder
    implements Builder<FinanceKitChanges, FinanceKitChangesBuilder> {
  _$FinanceKitChanges? _$v;

  ListBuilder<FinanceKitAccount>? _accounts;
  ListBuilder<FinanceKitAccount> get accounts =>
      _$this._accounts ??= ListBuilder<FinanceKitAccount>();
  set accounts(ListBuilder<FinanceKitAccount>? accounts) =>
      _$this._accounts = accounts;

  ListBuilder<String>? _deleted;
  ListBuilder<String> get deleted => _$this._deleted ??= ListBuilder<String>();
  set deleted(ListBuilder<String>? deleted) => _$this._deleted = deleted;

  String? _historyTokenAfter;
  String? get historyTokenAfter => _$this._historyTokenAfter;
  set historyTokenAfter(String? historyTokenAfter) =>
      _$this._historyTokenAfter = historyTokenAfter;

  String? _historyTokenBefore;
  String? get historyTokenBefore => _$this._historyTokenBefore;
  set historyTokenBefore(String? historyTokenBefore) =>
      _$this._historyTokenBefore = historyTokenBefore;

  ListBuilder<FinanceKitCharge>? _inserted;
  ListBuilder<FinanceKitCharge> get inserted =>
      _$this._inserted ??= ListBuilder<FinanceKitCharge>();
  set inserted(ListBuilder<FinanceKitCharge>? inserted) =>
      _$this._inserted = inserted;

  ListBuilder<FinanceKitCharge>? _updated;
  ListBuilder<FinanceKitCharge> get updated =>
      _$this._updated ??= ListBuilder<FinanceKitCharge>();
  set updated(ListBuilder<FinanceKitCharge>? updated) =>
      _$this._updated = updated;

  FinanceKitChangesBuilder() {
    FinanceKitChanges._defaults(this);
  }

  FinanceKitChangesBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _accounts = $v.accounts.toBuilder();
      _deleted = $v.deleted?.toBuilder();
      _historyTokenAfter = $v.historyTokenAfter;
      _historyTokenBefore = $v.historyTokenBefore;
      _inserted = $v.inserted?.toBuilder();
      _updated = $v.updated?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FinanceKitChanges other) {
    _$v = other as _$FinanceKitChanges;
  }

  @override
  void update(void Function(FinanceKitChangesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FinanceKitChanges build() => _build();

  _$FinanceKitChanges _build() {
    _$FinanceKitChanges _$result;
    try {
      _$result = _$v ??
          _$FinanceKitChanges._(
            accounts: accounts.build(),
            deleted: _deleted?.build(),
            historyTokenAfter: BuiltValueNullFieldError.checkNotNull(
                historyTokenAfter, r'FinanceKitChanges', 'historyTokenAfter'),
            historyTokenBefore: historyTokenBefore,
            inserted: _inserted?.build(),
            updated: _updated?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'accounts';
        accounts.build();
        _$failedField = 'deleted';
        _deleted?.build();

        _$failedField = 'inserted';
        _inserted?.build();
        _$failedField = 'updated';
        _updated?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'FinanceKitChanges', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
