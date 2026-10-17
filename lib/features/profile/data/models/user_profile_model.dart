import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.image,
    required this.city,
    required this.country,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return UserProfileModel(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      image: json['image'] as String,
      city: address?['city'] as String?,
      country: address?['country'] as String?,
    );
  }

  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String image;
  final String? city;
  final String? country;

  UserProfile toEntity() => UserProfile(
    firstName: firstName,
    lastName: lastName,
    username: username,
    email: email,
    phone: phone,
    image: image,
    city: city,
    country: country,
  );
}
