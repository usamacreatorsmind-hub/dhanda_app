import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String? phoneNumber;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? selectedBusinessId;
  final String language;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    this.phoneNumber,
    this.email,
    this.displayName,
    this.photoUrl,
    this.selectedBusinessId,
    this.language = 'hi',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      phoneNumber: map['phoneNumber'] as String?,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      selectedBusinessId: map['selectedBusinessId'] as String?,
      language: map['language'] as String? ?? 'hi',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'selectedBusinessId': selectedBusinessId,
      'language': language,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? email,
    String? displayName,
    String? photoUrl,
    String? selectedBusinessId,
    String? language,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      selectedBusinessId: selectedBusinessId ?? this.selectedBusinessId,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        phoneNumber,
        email,
        displayName,
        photoUrl,
        selectedBusinessId,
        language,
        createdAt,
      ];
}
