class CrewMemberModel {
  final String name;
  final String job;

  CrewMemberModel({
    required this.name,
    required this.job,
  });

  factory CrewMemberModel.fromJson(Map<String, dynamic> json) {
    return CrewMemberModel(
      name: json['name'],
      job: json['job'],
    );
  }
}
