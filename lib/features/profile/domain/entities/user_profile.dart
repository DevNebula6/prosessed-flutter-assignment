import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phone,
    required this.image,
    this.city,
    this.country,
  });

  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phone;
  final String image;
  final String? city;
  final String? country;

  String get fullName => '$firstName $lastName';

  /// "City, Country" with whichever parts are known, or null.
  String? get location {
    final parts = [?city, ?country];
    return parts.isEmpty ? null : parts.join(', ');
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    username,
    email,
    phone,
    image,
    city,
    country,
  ];
}
