import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/profile/domain/entities/user_profile.dart';
import 'package:shopsphere/features/profile/domain/usecases/get_profile.dart';
import 'package:shopsphere/features/profile/presentation/cubit/profile_cubit.dart';

class MockGetProfile extends Mock implements GetProfile {}

void main() {
  late MockGetProfile getProfile;

  const profile = UserProfile(
    firstName: 'Emily',
    lastName: 'Johnson',
    username: 'emilys',
    email: 'emily.johnson@x.dummyjson.com',
    phone: '+81 965-431-3024',
    image: 'https://dummyjson.com/icon/emilys/128',
  );

  setUp(() => getProfile = MockGetProfile());

  blocTest<ProfileCubit, ProfileState>(
    'emits loading then the profile',
    setUp: () =>
        when(() => getProfile()).thenAnswer((_) async => const Ok(profile)),
    build: () => ProfileCubit(getProfile),
    act: (cubit) => cubit.load(),
    expect: () => [const ProfileLoading(), const ProfileLoaded(profile)],
  );

  blocTest<ProfileCubit, ProfileState>(
    'emits the failure when loading fails',
    setUp: () =>
        when(() => getProfile())
            .thenAnswer((_) async => const Err(NetworkFailure())),
    build: () => ProfileCubit(getProfile),
    act: (cubit) => cubit.load(),
    expect: () => [
      const ProfileLoading(),
      const ProfileError(NetworkFailure()),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'keeps the profile on screen while refreshing',
    setUp: () =>
        when(() => getProfile()).thenAnswer((_) async => const Ok(profile)),
    build: () => ProfileCubit(getProfile),
    seed: () => const ProfileLoaded(profile),
    act: (cubit) => cubit.load(),
    expect: () => <ProfileState>[],
  );
}
