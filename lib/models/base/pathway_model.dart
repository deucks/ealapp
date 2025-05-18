import 'package:json_annotation/json_annotation.dart';

part 'pathway_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PathwayModel {
  String? id;
  String? name;
  String? description;
  String? backgroundImage;
  String? difficulty;
  String? scenarioForMl;
  DateTime? created;
  DateTime? updated;

  PathwayModel({
    this.id,
    this.name,
    this.description,
    this.backgroundImage,
    this.difficulty,
    this.scenarioForMl,
    this.created,
    this.updated,
  });

  factory PathwayModel.fromJson(Map<String, dynamic> json) =>
      _$PathwayModelFromJson(json);
  Map<String, dynamic> toJson() => _$PathwayModelToJson(this);
}
