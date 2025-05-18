// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_ml_output.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LastMlOutput _$LastMlOutputFromJson(Map<String, dynamic> json) => LastMlOutput(
  reply: json['reply'] as String?,
  feedback: json['feedback'] as String?,
  adjustDifficulty: json['adjust_difficulty'] as String?,
  possibleCorrectResponses:
      (json['possible_correct_responses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
);

Map<String, dynamic> _$LastMlOutputToJson(LastMlOutput instance) =>
    <String, dynamic>{
      'reply': instance.reply,
      'feedback': instance.feedback,
      'adjust_difficulty': instance.adjustDifficulty,
      'possible_correct_responses': instance.possibleCorrectResponses,
    };
