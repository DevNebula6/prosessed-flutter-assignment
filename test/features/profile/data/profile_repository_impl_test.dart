import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/core/error/result.dart';
import 'package:shopsphere/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:shopsphere/features/profile/data/models/user_profile_model.dart';
import 'package:shopsphere/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:shopsphere/features/profile/domain/entities/user_profile.dart';

import '../../../helpers/fixture_reader.dart';

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

void main() {
  late MockProfileRemoteDataSource remote;
  late ProfileRepositoryImpl repository;

  const emily = UserProfile(
    firstName: 'Emily',
    lastName: 'Johnson',
    username: 'emilys',
    email: 'emily.johnson@x.dummyjson.com',
    phone: '+81 965-431-3024',
    image: 'https://dummyjson.com/icon/emilys/128',
    city: 'Phoenix',
    country: 'United States',
  );

  setUp(() {
    remote = MockProfileRemoteDataSource();
    repository = ProfileRepositoryImpl(remote);
  });

  test('parses the profile from an auth/me response', () {
    final json = fixture('me.json') as Map<String, dynamic>;

    final profile = UserProfileModel.fromJson(json).toEntity();

    expect(profile, emily);
    expect(profile.fullName, 'Emily Johnson');
    expect(profile.location, 'Phoenix, United States');
  });

  test('location is null when the address is missing', () {
    final json = Map<String, dynamic>.of(
      fixture('me.json') as Map<String, dynamic>,
    )..remove('address');

    expect(UserProfileModel.fromJson(json).toEntity().location, isNull);
  });

  test('getProfile returns the profile', () async {
    when(() => remote.getProfile()).thenAnswer(
      (_) async =>
          UserProfileModel.fromJson(fixture('me.json') as Map<String, dynamic>),
    );

    expect(await repository.getProfile(), const Ok<UserProfile>(emily));
  });

  test('getProfile returns UnauthorizedFailure for a rejected token', () async {
    final options = RequestOptions(path: '/auth/me');
    when(() => remote.getProfile()).thenThrow(
      DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: options, statusCode: 401),
      ),
    );

    expect(
      await repository.getProfile(),
      const Err<UserProfile>(UnauthorizedFailure()),
    );
  });
}
