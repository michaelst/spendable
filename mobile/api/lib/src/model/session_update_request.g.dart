// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SessionUpdateRequest extends SessionUpdateRequest {
  @override
  final String apnsToken;

  factory _$SessionUpdateRequest(
          [void Function(SessionUpdateRequestBuilder)? updates]) =>
      (SessionUpdateRequestBuilder()..update(updates))._build();

  _$SessionUpdateRequest._({required this.apnsToken}) : super._();
  @override
  SessionUpdateRequest rebuild(
          void Function(SessionUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SessionUpdateRequestBuilder toBuilder() =>
      SessionUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SessionUpdateRequest && apnsToken == other.apnsToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, apnsToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SessionUpdateRequest')
          ..add('apnsToken', apnsToken))
        .toString();
  }
}

class SessionUpdateRequestBuilder
    implements Builder<SessionUpdateRequest, SessionUpdateRequestBuilder> {
  _$SessionUpdateRequest? _$v;

  String? _apnsToken;
  String? get apnsToken => _$this._apnsToken;
  set apnsToken(String? apnsToken) => _$this._apnsToken = apnsToken;

  SessionUpdateRequestBuilder() {
    SessionUpdateRequest._defaults(this);
  }

  SessionUpdateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _apnsToken = $v.apnsToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SessionUpdateRequest other) {
    _$v = other as _$SessionUpdateRequest;
  }

  @override
  void update(void Function(SessionUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SessionUpdateRequest build() => _build();

  _$SessionUpdateRequest _build() {
    final _$result = _$v ??
        _$SessionUpdateRequest._(
          apnsToken: BuiltValueNullFieldError.checkNotNull(
              apnsToken, r'SessionUpdateRequest', 'apnsToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
