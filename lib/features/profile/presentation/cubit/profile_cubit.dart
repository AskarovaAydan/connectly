import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final CreateProfileUseCase createProfileUseCase;
  final GetProfileUseCase getProfileUseCase;

  ProfileCubit(this.createProfileUseCase, this.getProfileUseCase)
    : super(ProfileInitial());

  Future<void> createProfile({
    required String uid,
    required String name,
    required String username,
    required String bio,
    File? imageFile,
  }) async {
    emit(ProfileLoading());
    try {
      final profile = await createProfileUseCase(
        uid: uid,
        name: name,
        username: username,
        bio: bio,
        imageFile: imageFile,
      );
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> getProfile(String uid) async {
    emit(ProfileLoading());
    try {
      final profile = await getProfileUseCase(uid);
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
