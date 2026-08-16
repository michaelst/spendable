// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SessionRequestProviderEnum _$sessionRequestProviderEnum_apple =
    const SessionRequestProviderEnum._('apple');
const SessionRequestProviderEnum _$sessionRequestProviderEnum_google =
    const SessionRequestProviderEnum._('google');

SessionRequestProviderEnum _$sessionRequestProviderEnumValueOf(String name) {
  switch (name) {
    case 'apple':
      return _$sessionRequestProviderEnum_apple;
    case 'google':
      return _$sessionRequestProviderEnum_google;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SessionRequestProviderEnum> _$sessionRequestProviderEnumValues =
    BuiltSet<SessionRequestProviderEnum>(const <SessionRequestProviderEnum>[
  _$sessionRequestProviderEnum_apple,
  _$sessionRequestProviderEnum_google,
]);

Serializer<SessionRequestProviderEnum> _$sessionRequestProviderEnumSerializer =
    _$SessionRequestProviderEnumSerializer();

class _$SessionRequestProviderEnumSerializer
    implements PrimitiveSerializer<SessionRequestProviderEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'apple': 'apple',
    'google': 'google',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'apple': 'apple',
    'google': 'google',
  };

  @override
  final Iterable<Type> types = const <Type>[SessionRequestProviderEnum];
  @override
  final String wireName = 'SessionRequestProviderEnum';

  @override
  Object serialize(Serializers serializers, SessionRequestProviderEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SessionRequestProviderEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SessionRequestProviderEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SessionRequest extends SessionRequest {
  @override
  final String? deviceName;
  @override
  final String idToken;
  @override
  final SessionRequestProviderEnum provider;

  factory _$SessionRequest([void Function(SessionRequestBuilder)? updates]) =>
      (SessionRequestBuilder()..update(updates))._build();

  _$SessionRequest._(
      {this.deviceName, required this.idToken, required this.provider})
      : super._();
  @override
  SessionRequest rebuild(void Function(SessionRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SessionRequestBuilder toBuilder() => SessionRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SessionRequest &&
        deviceName == other.deviceName &&
        idToken == other.idToken &&
        provider == other.provider;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deviceName.hashCode);
    _$hash = $jc(_$hash, idToken.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SessionRequest')
          ..add('deviceName', deviceName)
          ..add('idToken', idToken)
          ..add('provider', provider))
        .toString();
  }
}

class SessionRequestBuilder
    implements Builder<SessionRequest, SessionRequestBuilder> {
  _$SessionRequest? _$v;

  String? _deviceName;
  String? get deviceName => _$this._deviceName;
  set deviceName(String? deviceName) => _$this._deviceName = deviceName;

  String? _idToken;
  String? get idToken => _$this._idToken;
  set idToken(String? idToken) => _$this._idToken = idToken;

  SessionRequestProviderEnum? _provider;
  SessionRequestProviderEnum? get provider => _$this._provider;
  set provider(SessionRequestProviderEnum? provider) =>
      _$this._provider = provider;

  SessionRequestBuilder() {
    SessionRequest._defaults(this);
  }

  SessionRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deviceName = $v.deviceName;
      _idToken = $v.idToken;
      _provider = $v.provider;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SessionRequest other) {
    _$v = other as _$SessionRequest;
  }

  @override
  void update(void Function(SessionRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SessionRequest build() => _build();

  _$SessionRequest _build() {
    final _$result = _$v ??
        _$SessionRequest._(
          deviceName: deviceName,
          idToken: BuiltValueNullFieldError.checkNotNull(
              idToken, r'SessionRequest', 'idToken'),
          provider: BuiltValueNullFieldError.checkNotNull(
              provider, r'SessionRequest', 'provider'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
