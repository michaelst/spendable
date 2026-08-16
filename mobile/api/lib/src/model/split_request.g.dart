// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SplitRequest extends SplitRequest {
  @override
  final String? name;
  @override
  final BuiltList<SplitLineRequest>? splitLines;

  factory _$SplitRequest([void Function(SplitRequestBuilder)? updates]) =>
      (SplitRequestBuilder()..update(updates))._build();

  _$SplitRequest._({this.name, this.splitLines}) : super._();
  @override
  SplitRequest rebuild(void Function(SplitRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SplitRequestBuilder toBuilder() => SplitRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SplitRequest &&
        name == other.name &&
        splitLines == other.splitLines;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, splitLines.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SplitRequest')
          ..add('name', name)
          ..add('splitLines', splitLines))
        .toString();
  }
}

class SplitRequestBuilder
    implements Builder<SplitRequest, SplitRequestBuilder> {
  _$SplitRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ListBuilder<SplitLineRequest>? _splitLines;
  ListBuilder<SplitLineRequest> get splitLines =>
      _$this._splitLines ??= ListBuilder<SplitLineRequest>();
  set splitLines(ListBuilder<SplitLineRequest>? splitLines) =>
      _$this._splitLines = splitLines;

  SplitRequestBuilder() {
    SplitRequest._defaults(this);
  }

  SplitRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _splitLines = $v.splitLines?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SplitRequest other) {
    _$v = other as _$SplitRequest;
  }

  @override
  void update(void Function(SplitRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SplitRequest build() => _build();

  _$SplitRequest _build() {
    _$SplitRequest _$result;
    try {
      _$result = _$v ??
          _$SplitRequest._(
            name: name,
            splitLines: _splitLines?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'splitLines';
        _splitLines?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SplitRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
