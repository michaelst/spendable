// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$Split extends Split {
  @override
  final DateTime? archivedAt;
  @override
  final String id;
  @override
  final String name;
  @override
  final BuiltList<SplitLine> splitLines;

  factory _$Split([void Function(SplitBuilder)? updates]) =>
      (SplitBuilder()..update(updates))._build();

  _$Split._(
      {this.archivedAt,
      required this.id,
      required this.name,
      required this.splitLines})
      : super._();
  @override
  Split rebuild(void Function(SplitBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SplitBuilder toBuilder() => SplitBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Split &&
        archivedAt == other.archivedAt &&
        id == other.id &&
        name == other.name &&
        splitLines == other.splitLines;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, archivedAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, splitLines.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Split')
          ..add('archivedAt', archivedAt)
          ..add('id', id)
          ..add('name', name)
          ..add('splitLines', splitLines))
        .toString();
  }
}

class SplitBuilder implements Builder<Split, SplitBuilder> {
  _$Split? _$v;

  DateTime? _archivedAt;
  DateTime? get archivedAt => _$this._archivedAt;
  set archivedAt(DateTime? archivedAt) => _$this._archivedAt = archivedAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ListBuilder<SplitLine>? _splitLines;
  ListBuilder<SplitLine> get splitLines =>
      _$this._splitLines ??= ListBuilder<SplitLine>();
  set splitLines(ListBuilder<SplitLine>? splitLines) =>
      _$this._splitLines = splitLines;

  SplitBuilder() {
    Split._defaults(this);
  }

  SplitBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _archivedAt = $v.archivedAt;
      _id = $v.id;
      _name = $v.name;
      _splitLines = $v.splitLines.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Split other) {
    _$v = other as _$Split;
  }

  @override
  void update(void Function(SplitBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Split build() => _build();

  _$Split _build() {
    _$Split _$result;
    try {
      _$result = _$v ??
          _$Split._(
            archivedAt: archivedAt,
            id: BuiltValueNullFieldError.checkNotNull(id, r'Split', 'id'),
            name: BuiltValueNullFieldError.checkNotNull(name, r'Split', 'name'),
            splitLines: splitLines.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'splitLines';
        splitLines.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'Split', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
