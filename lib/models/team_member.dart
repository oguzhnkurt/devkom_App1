class TeamMember {
  final String id;
  final String name;
  final String role;
  final String bio;
  final String imageUrl;
  final String email;
  final List<String> skills;

  TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.bio,
    required this.imageUrl,
    required this.email,
    required this.skills,
  });

  // Convert TeamMember to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'bio': bio,
      'imageUrl': imageUrl,
      'email': email,
      'skills': skills,
    };
  }

  // // REMOVED: Firebase-specific method
  // // factory TeamMember.fromFirestore(DocumentSnapshot doc) { ... }

  // Create TeamMember from Map
  factory TeamMember.fromMap(Map<String, dynamic> map) {
    return TeamMember(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      bio: map['bio'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      email: map['email'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
    );
  }

  // Copy with method for immutability
  TeamMember copyWith({
    String? id,
    String? name,
    String? role,
    String? bio,
    String? imageUrl,
    String? email,
    List<String>? skills,
  }) {
    return TeamMember(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      email: email ?? this.email,
      skills: skills ?? this.skills,
    );
  }
}
