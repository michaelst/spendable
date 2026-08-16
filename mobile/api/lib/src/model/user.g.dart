// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$User extends User {
  @override
  final int bankLimit;
  @override
  final String id;
  @override
  final BuiltList<Identity> identities;
  @override
  final String? image;

  factory _$User([void Function(UserBuilder)? updates]) =>
      (UserBuilder()..update(updates))._build();

  _$User._(
      {required this.bankLimit,
      required this.id,
      required this.identities,
      this.image})
      : super._();
  @override
  User rebuild(void Function(UserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserBuilder toBuilder() => UserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is User &&
        bankLimit == other.bankLimit &&
        id == other.id &&
        identities == other.identities &&
        image == other.image;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bankLimit.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, identities.hashCode);
    _$hash = $jc(_$hash, image.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'User')
          ..add('bankLimit', bankLimit)
          ..add('id', id)
          ..add('identities', identities)
          ..add('image', image))
        .toString();
  }
}

class UserBuilder implements Builder<User, UserBuilder> {
  _$User? _$v;

  int? _bankLimit;
  int? get bankLimit => _$this._bankLimit;
  set bankLimit(int? bankLimit) => _$this._bankLimit = bankLimit;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ListBuilder<Identity>? _identities;
  ListBuilder<Identity> get identities =>
      _$this._identities ??= ListBuilder<Identity>();
  set identities(ListBuilder<Identity>? identities) =>
      _$this._identities = identities;

  String? _image;
  String? get image => _$this._image;
  set image(String? image) => _$this._image = image;

  UserBuilder() {
    User._defaults(this);
  }

  UserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bankLimit = $v.bankLimit;
      _id = $v.id;
      _identities = $v.identities.toBuilder();
      _image = $v.image;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(User other) {
    _$v = other as _$User;
  }

  @override
  void update(void Function(UserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  User build() => _build();

  _$User _build() {
    _$User _$result;
    try {
      _$result = _$v ??
          _$User._(
            bankLimit: BuiltValueNullFieldError.checkNotNull(
                bankLimit, r'User', 'bankLimit'),
            id: BuiltValueNullFieldError.checkNotNull(id, r'User', 'id'),
            identities: identities.build(),
            image: image,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'identities';
        identities.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'User', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
