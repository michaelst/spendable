// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_token.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LinkToken extends LinkToken {
  @override
  final String linkToken;

  factory _$LinkToken([void Function(LinkTokenBuilder)? updates]) =>
      (LinkTokenBuilder()..update(updates))._build();

  _$LinkToken._({required this.linkToken}) : super._();
  @override
  LinkToken rebuild(void Function(LinkTokenBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LinkTokenBuilder toBuilder() => LinkTokenBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LinkToken && linkToken == other.linkToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, linkToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LinkToken')
          ..add('linkToken', linkToken))
        .toString();
  }
}

class LinkTokenBuilder implements Builder<LinkToken, LinkTokenBuilder> {
  _$LinkToken? _$v;

  String? _linkToken;
  String? get linkToken => _$this._linkToken;
  set linkToken(String? linkToken) => _$this._linkToken = linkToken;

  LinkTokenBuilder() {
    LinkToken._defaults(this);
  }

  LinkTokenBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _linkToken = $v.linkToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LinkToken other) {
    _$v = other as _$LinkToken;
  }

  @override
  void update(void Function(LinkTokenBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LinkToken build() => _build();

  _$LinkToken _build() {
    final _$result = _$v ??
        _$LinkToken._(
          linkToken: BuiltValueNullFieldError.checkNotNull(
              linkToken, r'LinkToken', 'linkToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
