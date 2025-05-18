import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pathway_history.g.dart';

enum PathwayHistoryType { input, reply }

@JsonSerializable(explicitToJson: true)
class PathwayHistory {
  String id;
  String? input;
  String? reply;
  String? feedback;
  String? adjustDifficulty;
  PathwayHistoryType? type;

  PathwayHistory({
    required this.id,
    this.input,
    this.reply,
    this.feedback,
    this.adjustDifficulty,
    this.type,
  });

  factory PathwayHistory.fromJson(Map<String, dynamic> json) =>
      _$PathwayHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$PathwayHistoryToJson(this);
}
