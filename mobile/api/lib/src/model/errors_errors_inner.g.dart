// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'errors_errors_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ErrorsErrorsInner extends ErrorsErrorsInner {
  @override
  final String code;
  @override
  final String detail;
  @override
  final ErrorsErrorsInnerSource? source_;

  factory _$ErrorsErrorsInner(
          [void Function(ErrorsErrorsInnerBuilder)? updates]) =>
      (ErrorsErrorsInnerBuilder()..update(updates))._build();

  _$ErrorsErrorsInner._(
      {required this.code, required this.detail, this.source_})
      : super._();
  @override
  ErrorsErrorsInner rebuild(void Function(ErrorsErrorsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ErrorsErrorsInnerBuilder toBuilder() =>
      ErrorsErrorsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ErrorsErrorsInner &&
        code == other.code &&
        detail == other.detail &&
        source_ == other.source_;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, detail.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ErrorsErrorsInner')
          ..add('code', code)
          ..add('detail', detail)
          ..add('source_', source_))
        .toString();
  }
}

class ErrorsErrorsInnerBuilder
    implements Builder<ErrorsErrorsInner, ErrorsErrorsInnerBuilder> {
  _$ErrorsErrorsInner? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _detail;
  String? get detail => _$this._detail;
  set detail(String? detail) => _$this._detail = detail;

  ErrorsErrorsInnerSourceBuilder? _source_;
  ErrorsErrorsInnerSourceBuilder get source_ =>
      _$this._source_ ??= ErrorsErrorsInnerSourceBuilder();
  set source_(ErrorsErrorsInnerSourceBuilder? source_) =>
      _$this._source_ = source_;

  ErrorsErrorsInnerBuilder() {
    ErrorsErrorsInner._defaults(this);
  }

  ErrorsErrorsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _detail = $v.detail;
      _source_ = $v.source_?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ErrorsErrorsInner other) {
    _$v = other as _$ErrorsErrorsInner;
  }

  @override
  void update(void Function(ErrorsErrorsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ErrorsErrorsInner build() => _build();

  _$ErrorsErrorsInner _build() {
    _$ErrorsErrorsInner _$result;
    try {
      _$result = _$v ??
          _$ErrorsErrorsInner._(
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'ErrorsErrorsInner', 'code'),
            detail: BuiltValueNullFieldError.checkNotNull(
                detail, r'ErrorsErrorsInner', 'detail'),
            source_: _source_?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'source_';
        _source_?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ErrorsErrorsInner', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
