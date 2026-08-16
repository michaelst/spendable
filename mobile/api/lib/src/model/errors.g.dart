// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'errors.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Errors extends Errors {
  @override
  final BuiltList<ErrorsErrorsInner> errors;

  factory _$Errors([void Function(ErrorsBuilder)? updates]) =>
      (ErrorsBuilder()..update(updates))._build();

  _$Errors._({required this.errors}) : super._();
  @override
  Errors rebuild(void Function(ErrorsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ErrorsBuilder toBuilder() => ErrorsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Errors && errors == other.errors;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, errors.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Errors')..add('errors', errors))
        .toString();
  }
}

class ErrorsBuilder implements Builder<Errors, ErrorsBuilder> {
  _$Errors? _$v;

  ListBuilder<ErrorsErrorsInner>? _errors;
  ListBuilder<ErrorsErrorsInner> get errors =>
      _$this._errors ??= ListBuilder<ErrorsErrorsInner>();
  set errors(ListBuilder<ErrorsErrorsInner>? errors) => _$this._errors = errors;

  ErrorsBuilder() {
    Errors._defaults(this);
  }

  ErrorsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _errors = $v.errors.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Errors other) {
    _$v = other as _$Errors;
  }

  @override
  void update(void Function(ErrorsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Errors build() => _build();

  _$Errors _build() {
    _$Errors _$result;
    try {
      _$result = _$v ??
          _$Errors._(
            errors: errors.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'errors';
        errors.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Errors', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
