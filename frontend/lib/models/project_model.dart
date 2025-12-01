class Project {
  final int? id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String country;
  final String zone; 
  final String status;
  final int approvalVotes;
  final int validationPositiveVotes;
  final int? proposerId;

  Project({
    this.id, required this.title, required this.description,
    required this.latitude, required this.longitude,
    required this.country, required this.zone, required this.status, required this.approvalVotes,
    this.validationPositiveVotes = 0,
    this.proposerId
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      country: json['country'] ?? 'Argentina',
      zone: json['zone'] ?? '',
      status: json['status'] ?? 'PROPOSED',
      approvalVotes: json['approvalVotes'] ?? 0,
      validationPositiveVotes: json['validationPositiveVotes'] ?? 0,
      proposerId: json['proposerId'],
    );
  }
}
