import 'dart:io';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasource/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createProfile(ProfileEntity profile) {
    return remoteDataSource.createProfile(profile);
  }

  @override
  Future<ProfileEntity> getProfile(String uid) {
    return remoteDataSource.getProfile(uid);
  }

  @override
  Future<String> uploadProfileImage({
    required String uid,
    required File imageFile,
  }) {
    return remoteDataSource.uploadProfileImage(uid: uid, imageFile: imageFile);
  }
}
