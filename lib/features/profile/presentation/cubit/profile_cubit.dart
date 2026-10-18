import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._getProfile) : super(const ProfileLoading());

  final GetProfile _getProfile;

  Future<void> load() async {
    // A pull to refresh keeps the current details on screen.
    if (state is! ProfileLoaded) emit(const ProfileLoading());

    final result = await _getProfile();
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => ProfileLoaded(value),
      Err(:final failure) => ProfileError(failure),
    });
  }
}
