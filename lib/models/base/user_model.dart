import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  String? id;
  String? email;
  bool? emailVisibility;
  String? name;
  String? avatar;
  DateTime? created;
  DateTime? updated;

  UserModel({
    this.id,
    this.email,
    this.emailVisibility,
    this.name,
    this.avatar,
    this.created,
    this.updated,
  });

  UserModel copyWith({
    String? id,
    String? email,
    bool? emailVisibility,
    String? name,
    String? avatar,
    DateTime? created,
    DateTime? updated,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      emailVisibility: emailVisibility ?? this.emailVisibility,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
