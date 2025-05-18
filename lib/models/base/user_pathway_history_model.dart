import 'package:ealapp/models/sup/last_ml_output.dart';
import 'package:ealapp/models/sup/pathway_history.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_pathway_history_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserPathwayHistoryModel {
  String? id;
  String? pathway;
  String? user;
  List<PathwayHistory>? conversationHistory;
  LastMlOutput? lastMlOutput;
  DateTime? created;
  DateTime? updated;

  UserPathwayHistoryModel({
    this.id,
    this.pathway,
    this.user,
    this.conversationHistory,
    // this.lastMlOutput,
    this.created,
    this.updated,
  });

  factory UserPathwayHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$UserPathwayHistoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserPathwayHistoryModelToJson(this);
}
