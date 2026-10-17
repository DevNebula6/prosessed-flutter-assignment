import '../../domain/entities/user.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      image: json['image'] as String,
    );
  }

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String image;

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'image': image,
  };

  User toEntity() => User(
    id: id,
    username: username,
    firstName: firstName,
    lastName: lastName,
    email: email,
    image: image,
  );
}
