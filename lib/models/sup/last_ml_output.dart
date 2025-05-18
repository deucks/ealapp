import 'package:json_annotation/json_annotation.dart';

part 'last_ml_output.g.dart';

@JsonSerializable(explicitToJson: true)
class LastMlOutput {
  String? reply;
  String? feedback;
  @JsonKey(name: 'adjust_difficulty')
  String? adjustDifficulty;
  @JsonKey(name: 'possible_correct_responses')
  List<String>? possibleCorrectResponses;

  LastMlOutput({
    this.reply,
    this.feedback,
    this.adjustDifficulty,
    this.possibleCorrectResponses,
  });

  factory LastMlOutput.fromJson(Map<String, dynamic> json) =>
      _$LastMlOutputFromJson(json);
  Map<String, dynamic> toJson() => _$LastMlOutputToJson(this);
}
