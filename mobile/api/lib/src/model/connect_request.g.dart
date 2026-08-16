// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connect_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConnectRequest extends ConnectRequest {
  @override
  final String publicToken;

  factory _$ConnectRequest([void Function(ConnectRequestBuilder)? updates]) =>
      (ConnectRequestBuilder()..update(updates))._build();

  _$ConnectRequest._({required this.publicToken}) : super._();
  @override
  ConnectRequest rebuild(void Function(ConnectRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConnectRequestBuilder toBuilder() => ConnectRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConnectRequest && publicToken == other.publicToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, publicToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConnectRequest')
          ..add('publicToken', publicToken))
        .toString();
  }
}

class ConnectRequestBuilder
    implements Builder<ConnectRequest, ConnectRequestBuilder> {
  _$ConnectRequest? _$v;

  String? _publicToken;
  String? get publicToken => _$this._publicToken;
  set publicToken(String? publicToken) => _$this._publicToken = publicToken;

  ConnectRequestBuilder() {
    ConnectRequest._defaults(this);
  }

  ConnectRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _publicToken = $v.publicToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConnectRequest other) {
    _$v = other as _$ConnectRequest;
  }

  @override
  void update(void Function(ConnectRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConnectRequest build() => _build();

  _$ConnectRequest _build() {
    final _$result = _$v ??
        _$ConnectRequest._(
          publicToken: BuiltValueNullFieldError.checkNotNull(
              publicToken, r'ConnectRequest', 'publicToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
