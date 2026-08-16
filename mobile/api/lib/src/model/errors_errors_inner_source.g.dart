// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'errors_errors_inner_source.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ErrorsErrorsInnerSource extends ErrorsErrorsInnerSource {
  @override
  final String? pointer;

  factory _$ErrorsErrorsInnerSource(
          [void Function(ErrorsErrorsInnerSourceBuilder)? updates]) =>
      (ErrorsErrorsInnerSourceBuilder()..update(updates))._build();

  _$ErrorsErrorsInnerSource._({this.pointer}) : super._();
  @override
  ErrorsErrorsInnerSource rebuild(
          void Function(ErrorsErrorsInnerSourceBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ErrorsErrorsInnerSourceBuilder toBuilder() =>
      ErrorsErrorsInnerSourceBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ErrorsErrorsInnerSource && pointer == other.pointer;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pointer.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ErrorsErrorsInnerSource')
          ..add('pointer', pointer))
        .toString();
  }
}

class ErrorsErrorsInnerSourceBuilder
    implements
        Builder<ErrorsErrorsInnerSource, ErrorsErrorsInnerSourceBuilder> {
  _$ErrorsErrorsInnerSource? _$v;

  String? _pointer;
  String? get pointer => _$this._pointer;
  set pointer(String? pointer) => _$this._pointer = pointer;

  ErrorsErrorsInnerSourceBuilder() {
    ErrorsErrorsInnerSource._defaults(this);
  }

  ErrorsErrorsInnerSourceBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pointer = $v.pointer;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ErrorsErrorsInnerSource other) {
    _$v = other as _$ErrorsErrorsInnerSource;
  }

  @override
  void update(void Function(ErrorsErrorsInnerSourceBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ErrorsErrorsInnerSource build() => _build();

  _$ErrorsErrorsInnerSource _build() {
    final _$result = _$v ??
        _$ErrorsErrorsInnerSource._(
          pointer: pointer,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
