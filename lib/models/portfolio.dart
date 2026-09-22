class Portfolio {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final DateTime? createdAt;

  Portfolio({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.createdAt,
  });
  //convert JSON data received from your backend/API into a Dart User object.
  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
  //it converts dart object to json data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
