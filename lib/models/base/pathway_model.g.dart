// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pathway_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PathwayModel _$PathwayModelFromJson(Map<String, dynamic> json) => PathwayModel(
  id: json['id'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  backgroundImage: json['backgroundImage'] as String?,
  difficulty: json['difficulty'] as String?,
  scenarioForMl: json['scenarioForMl'] as String?,
  created:
      json['created'] == null
          ? null
          : DateTime.parse(json['created'] as String),
  updated:
      json['updated'] == null
          ? null
          : DateTime.parse(json['updated'] as String),
);

Map<String, dynamic> _$PathwayModelToJson(PathwayModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'backgroundImage': instance.backgroundImage,
      'difficulty': instance.difficulty,
      'scenarioForMl': instance.scenarioForMl,
      'created': instance.created?.toIso8601String(),
      'updated': instance.updated?.toIso8601String(),
    };
