// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_pathway_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPathwayHistoryModel _$UserPathwayHistoryModelFromJson(
  Map<String, dynamic> json,
) => UserPathwayHistoryModel(
    id: json['id'] as String?,
    pathway: json['pathway'] as String?,
    user: json['user'] as String?,
    conversationHistory:
        (json['conversationHistory'] as List<dynamic>?)
            ?.map((e) => PathwayHistory.fromJson(e as Map<String, dynamic>))
            .toList(),
    created:
        json['created'] == null
            ? null
            : DateTime.parse(json['created'] as String),
    updated:
        json['updated'] == null
            ? null
            : DateTime.parse(json['updated'] as String),
  )
  ..lastMlOutput =
      json['lastMlOutput'] == null
          ? null
          : LastMlOutput.fromJson(json['lastMlOutput'] as Map<String, dynamic>);

Map<String, dynamic> _$UserPathwayHistoryModelToJson(
  UserPathwayHistoryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'pathway': instance.pathway,
  'user': instance.user,
  'conversationHistory':
      instance.conversationHistory?.map((e) => e.toJson()).toList(),
  'lastMlOutput': instance.lastMlOutput?.toJson(),
  'created': instance.created?.toIso8601String(),
  'updated': instance.updated?.toIso8601String(),
};
