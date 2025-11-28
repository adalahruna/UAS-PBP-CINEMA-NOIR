class CastMemberModel {
  final String name;
  final String character;
  final String? profilePath;

  CastMemberModel({
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory CastMemberModel.fromJson(Map<String, dynamic> json) {
    return CastMemberModel(
      name: json['name'],
      character: json['character'],
      profilePath: json['profile_path'],
    );
  }
}
