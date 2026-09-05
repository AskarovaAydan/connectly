import 'dart:io';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<void> createProfile(
    ProfileEntity profile,
  ); //"Bu ProfileEntity-ni götür və Firestore-da saxla."Deməli Entity repository ilə həm girə, həm də çıxa bilər.

  Future<ProfileEntity> getProfile(
    String uid,
  ); //"Mənə uid ver, mən sənə həmin user-in ProfileEntity-sini gətirim."

  Future<String> uploadProfileImage({
    //: şəkli yükləyib URL (String) qaytarır. Bu URL, sonra, UseCase səviyyəsində, əl ilə ProfileEntity-nin photoUrl sahəsinə yerləşdiriləcək.
    required String
    uid, //Entity ilə birbaşa əlaqəsi yoxdur, o, sadəcə ProfileEntity-ni yaratmaq üçün lazım olan bir hissəni (photoUrl) hazırlayır
    required File imageFile,
  });
}
/*
createProfile()	Profil məlumatını Firestore-a yazır
getProfile()	Firestore-dakı profili geri oxuyur

ProfileRepository isə:

"Profile ilə nə edə bilərik?"

sualının cavabıdır.

ProfileRepository
├── createProfile()
├── getProfile()
└── updateProfile()







---------------createProfile — ilk dəfə profil yaradır

İstifadəçi qeydiyyatdan keçir:

email: aydan@gmail.com
password: ****

Firebase Auth-da account yaranır:

Firebase Auth
└── uid: abc123
    email: aydan@gmail.com

Amma burada:

name
username
bio
photo

yoxdur.

İstifadəçi profil formasını doldurur:

Name: Aydan
Username: aydan04
Bio: Flutter Developer

Biz:

final profile = ProfileEntity(
  uid: uid,
  name: 'Aydan',
  username: 'aydan04',
  bio: 'Flutter Developer',
);

yaradıb:

await profileRepository.createProfile(profile);

deyirik.

Bu:

ProfileEntity
     ↓
createProfile()
     ↓
Firestore

deməkdir.

Firestore-da artıq:

profiles
   └── abc123
        ├── name: Aydan
        ├── username: aydan04
        └── bio: Flutter Developer

olur.

2. Bəs getProfile niyə lazımdır?

Çünki app bağlananda həmin ProfileEntity yox olur.

Məsələn sabah app-i açdın.

Flutter yaddaşında əvvəlki:

ProfileEntity(...)

obyekti yoxdur.

Amma məlumat Firestore-da qalır:

Firestore
   ↓
profiles/abc123
   ↓
name: Aydan
username: aydan04
bio: Flutter Developer

App açıldıqda biz deyirik:

final profile = await profileRepository.getProfile(uid);

Yəni:

"Bu uid-yə aid profili Firestore-dan mənə gətir."

Axın:

uid
 ↓
getProfile(uid)
 ↓
Firestore
 ↓
ProfileModel
 ↓
ProfileEntity
 ↓
Cubit
 ↓
UI
*/