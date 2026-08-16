// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IdentityProviderEnum _$identityProviderEnum_apple =
    const IdentityProviderEnum._('apple');
const IdentityProviderEnum _$identityProviderEnum_google =
    const IdentityProviderEnum._('google');

IdentityProviderEnum _$identityProviderEnumValueOf(String name) {
  switch (name) {
    case 'apple':
      return _$identityProviderEnum_apple;
    case 'google':
      return _$identityProviderEnum_google;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IdentityProviderEnum> _$identityProviderEnumValues =
    BuiltSet<IdentityProviderEnum>(const <IdentityProviderEnum>[
  _$identityProviderEnum_apple,
  _$identityProviderEnum_google,
]);

Serializer<IdentityProviderEnum> _$identityProviderEnumSerializer =
    _$IdentityProviderEnumSerializer();

class _$IdentityProviderEnumSerializer
    implements PrimitiveSerializer<IdentityProviderEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'apple': 'apple',
    'google': 'google',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'apple': 'apple',
    'google': 'google',
  };

  @override
  final Iterable<Type> types = const <Type>[IdentityProviderEnum];
  @override
  final String wireName = 'IdentityProviderEnum';

  @override
  Object serialize(Serializers serializers, IdentityProviderEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IdentityProviderEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IdentityProviderEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Identity extends Identity {
  @override
  final String id;
  @override
  final IdentityProviderEnum provider;

  factory _$Identity([void Function(IdentityBuilder)? updates]) =>
      (IdentityBuilder()..update(updates))._build();

  _$Identity._({required this.id, required this.provider}) : super._();
  @override
  Identity rebuild(void Function(IdentityBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IdentityBuilder toBuilder() => IdentityBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Identity && id == other.id && provider == other.provider;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Identity')
          ..add('id', id)
          ..add('provider', provider))
        .toString();
  }
}

class IdentityBuilder implements Builder<Identity, IdentityBuilder> {
  _$Identity? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  IdentityProviderEnum? _provider;
  IdentityProviderEnum? get provider => _$this._provider;
  set provider(IdentityProviderEnum? provider) => _$this._provider = provider;

  IdentityBuilder() {
    Identity._defaults(this);
  }

  IdentityBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _provider = $v.provider;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Identity other) {
    _$v = other as _$Identity;
  }

  @override
  void update(void Function(IdentityBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Identity build() => _build();

  _$Identity _build() {
    final _$result = _$v ??
        _$Identity._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Identity', 'id'),
          provider: BuiltValueNullFieldError.checkNotNull(
              provider, r'Identity', 'provider'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
