import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileRemoteDataSource {
  final FirebaseFirestore
  firestore; //bu DataSource iki Firebase servisi ilə işləyir (Firestore + Storage), ona görə hər ikisini constructor-dan alırıq.
  final FirebaseStorage storage;

  ProfileRemoteDataSource(this.firestore, this.storage);

  Future<void> createProfile(ProfileEntity profile) async {
    await firestore.collection('users').doc(profile.uid).set({
      'uid': profile
          .uid, //.collection('users') — Firestore-da "users" adlı bir cədvəl (kolleksiya) seçirik.doc(profile.uid) — bu kolleksiyada, id-si uid olan bir sənəd seçirik (yoxdursa, yaradılacaq).set({...}) — bu sənədə Map (açar-dəyər) şəklində data yazırıq. Diqqət et: Firestore, Dart obyektlərini birbaşa qəbul etmir — Map<String, dynamic> formatına çevirmək lazımdır (bu, UserEntity-ni Firebase-ə "tərcümə etmək"dir, tərsinə əməliyyat)
      'name': profile.name,
      'username': profile.username,
      'bio': profile.bio,
      'photoUrl': profile.photoUrl,
    });
  }

  Future<ProfileEntity> getProfile(String uid) async {
    final doc = await firestore
        .collection('users')
        .doc(uid)
        .get(); //.get() — sənədi Firestore-dan oxuyur

    if (!doc.exists) {
      //doc.exists — sənəd həqiqətən varmı, yoxlayırıq
      throw Exception('Profil tapılmadı');
    }

    final data = doc
        .data()!; //doc.data() — sənədin içindəki Map-i qaytarır, ! işarəsi ilə "bu, null deyil, əminəm" deyirik (çünki exists yoxlamasından keçmişik)

    return ProfileEntity(
      uid: data['uid'],
      name: data['name'],
      username: data['username'],
      bio: data['bio'],
      photoUrl: data['photoUrl'],
    );
  }

  Future<String> uploadProfileImage({
    required String uid,
    required File imageFile,
  }) async {
    final ref = storage
        .ref()
        .child('profile_images')
        .child(
          '$uid.jpg',
        ); //storage.ref() — Storage-ın "kök qovluğuna" istinad yaradır
    //.child('profile_images').child('$uid.jpg') — profile_images/UID.jpg yolunu təyin edir (hər istifadəçinin şəkli, öz uid-i ilə adlanır ki, üst-üstə düşməsin)
    await ref.putFile(imageFile);
    //.putFile(imageFile) — real faylı Storage-a yükləyir (vaxt aparır, await)
    final downloadUrl = await ref.getDownloadURL();
    //.getDownloadURL() — yükləmə bitəndən sonra, həmin şəklin ictimai linkini alır — bu, Future<String>-in qaytardığı dəyərdir
    return downloadUrl; //hemin linki bu uploadProfileImage() metodu harda cagrilirsa ora qaytarir yeni repoya
  }
}
