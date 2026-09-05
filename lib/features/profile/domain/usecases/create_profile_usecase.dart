import 'dart:io';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class CreateProfileUseCase {
  final ProfileRepository repository;

  CreateProfileUseCase(this.repository);

  Future<ProfileEntity> call({
    required String uid,
    required String name,
    required String username,
    required String bio,
    File? imageFile, //sekil secmiyede bilerik
  }) async {
    String? photoUrl;

    if (imageFile != null) {
      photoUrl = await repository.uploadProfileImage(
        uid: uid,
        imageFile:
            imageFile, //secsek storageye yukleyir ordaan url alir ve artiq teze deyer photourlde saxlanilr
      );
    } //heleki storage akktivlesdirmemisik deye sekil secmiyek

    final profile = ProfileEntity(
      uid: uid,
      name: name,
      username: username,
      bio: bio,
      photoUrl:
          photoUrl, //bu firebaseden url kimi gelir diger 4 deyerle birlesdilir
    );

    await repository.createProfile(profile); //Sonra Firestore-a yazırıq
    //İndi bu tam ProfileEntity-ni Firestore-a yazırıq — bu, ProfileRepositoryImpl.createProfile-ə gedir, o da DataSource-a, o da Firestore-da users/xYz789 sənədini yaradır.

    return profile;
  }
}//Yeni burda esas fikir verdiyimiz hisse imagedi cunki digerleri zaten varda bu image varsa firebase yaz url kimi al ,diger 4 deyerle birlesdir gonder tezden firebaseye
/*
GİRİŞ:  uid, name, username, bio, imageFile (5 ayrı parça)
              ↓
     [şəkil varsa, Storage-a yüklə → URL al]
              ↓
     bu URL-i digər 4 parça ilə BİRLƏŞDİR
              ↓
        ProfileEntity (tam, hazır obyekt)
              ↓
        Firestore-a YAZ
        */