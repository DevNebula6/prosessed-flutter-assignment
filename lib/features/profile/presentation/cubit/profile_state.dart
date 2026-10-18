part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

final class ProfileError extends ProfileState {
  const ProfileError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
