// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String?,
  email: json['email'] as String?,
  emailVisibility: json['emailVisibility'] as bool?,
  name: json['name'] as String?,
  avatar: json['avatar'] as String?,
  created:
      json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
  updated:
      json['updated'] == null
          ? null
          : DateTime.parse(json['updated'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'emailVisibility': instance.emailVisibility,
  'name': instance.name,
  'avatar': instance.avatar,
  'created': instance.created?.toIso8601String(),
  'updated': instance.updated?.toIso8601String(),
};
