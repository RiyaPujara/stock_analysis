class User {
  final int id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.createdAt,
  });
  //convert JSON data received from your backend/API into a Dart User object.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
  //it converts dart object to json data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
