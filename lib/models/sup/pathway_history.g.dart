// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pathway_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PathwayHistory _$PathwayHistoryFromJson(Map<String, dynamic> json) =>
    PathwayHistory(
      id: json['id'] as String,
      input: json['input'] as String?,
      reply: json['reply'] as String?,
      feedback: json['feedback'] as String?,
      adjustDifficulty: json['adjustDifficulty'] as String?,
      type: $enumDecodeNullable(_$PathwayHistoryTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$PathwayHistoryToJson(PathwayHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'input': instance.input,
      'reply': instance.reply,
      'feedback': instance.feedback,
      'adjustDifficulty': instance.adjustDifficulty,
      'type': _$PathwayHistoryTypeEnumMap[instance.type],
    };

const _$PathwayHistoryTypeEnumMap = {
  PathwayHistoryType.input: 'input',
  PathwayHistoryType.reply: 'reply',
};
