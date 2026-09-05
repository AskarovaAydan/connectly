import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post_entity.dart';

class PostRemoteDataSource {
  final FirebaseFirestore firestore;

  PostRemoteDataSource(this.firestore);

  Future<void> createPost(PostEntity post) async {
    await firestore.collection('posts').add({
      'userId': post.userId,
      'userName': post.userName,
      'userPhotoUrl': post.userPhotoUrl,
      'content': post.content,
      'createdAt': post.createdAt.toIso8601String(),
      'likedBy': post.likedBy,
    });
  }

  Stream<List<PostEntity>> getPosts() {
    return firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots() //snapshots  hamsin getirmek demekdi cunki streamin methoduudr,get ise future methodu tek obyekt getir demekdi
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return PostEntity(
              id: doc
                  .id, //.add(...) işlətdiyimiz üçün, Firestore öz-özünə ID yaratdı — bu ID, sənədin məlumatının içində deyil, sənədin özünün "adı"dır (doc.id bu adı verir).
              userId: data['userId'],
              userName: data['userName'],
              userPhotoUrl: data['userPhotoUrl'],
              content: data['content'],
              createdAt: DateTime.parse(data['createdAt']),
              likedBy: List<String>.from(data['likedBy'] ?? []),
            );
          }).toList();
        });
  }

  Future<void> toggleLike({required String postId, required String uid}) async {
    final docRef = firestore.collection('posts').doc(postId);
    final doc = await docRef.get();
    final likedBy = List<String>.from(doc.data()?['likedBy'] ?? []);

    if (likedBy.contains(uid)) {
      likedBy.remove(uid);
    } else {
      likedBy.add(uid);
    }

    await docRef.update({'likedBy': likedBy});
  }
}
/*
1. createPost — niyə .doc(uid).set() yox, .add()?

await firestore.collection('posts').add({...});

Yadına gəlsin, Profile-da belə yazmışdıq:

firestore.collection('users').doc(profile.uid).set({...}); // KONKRET ID veririk

Amma postlarda konkret ID verməyə ehtiyac yoxdur — hər post, öz-özlüyündə unikal olmalıdır, amma hansı ID olacağı fərq etmir (profile.uid kimi əlaqəli bir ID yoxdur). Ona görə .add(...) işlədirik — bu, Firestore-a deyir: "özün random, unikal bir ID yarat".

2. createdAt: post.createdAt.toIso8601String() — niyə String-ə çeviririk?

Firestore, Dart-ın DateTime obyektini birbaşa qəbul etmir (əslində Firestore-un öz Timestamp tipi var, amma sadəlik üçün mən String formatını seçdim). .toIso8601String() — DateTime-ı, standart bir mətn formatına çevirir (məsələn "2026-09-05T14:30:00.000"), bu format sonra yenidən DateTime-a çevrilə bilər (DateTime.parse(...) ilə, aşağıda görəcəyik).

3. getPosts() — bu, ən mühüm hissədir

firestore
    .collection('posts')
    .orderBy('createdAt', descending: true)
    .snapshots()
.orderBy('createdAt', descending: true) — postları tarix üzrə, ən yenidən ən köhnəyə sırala (descending: true = azalan sıra)
.snapshots() — bax, məhz bura Stream yaranır! .get() (bir dəfəlik) əvəzinə, .snapshots() davamlı bir axın açır — Firestore-da bu kolleksiyada hər dəyişiklikdə, yeni "şəkil" (snapshot) göndəriləcək

4. .map((snapshot) { ... }) — niyə lazımdır?

.snapshots()-un qaytardığı Stream, QuerySnapshot adlı Firestore-un öz formatını verir — bizim PostEntity siyahımız deyil. Ona görə .map() ilə, hər gələn snapshot-u bizim istədiyimiz formata (List<PostEntity>) çeviririk.

.map((snapshot) {
  return snapshot.docs.map((doc) {
    ...
    return PostEntity(...);
  }).toList();
});

Diqqət et — burada iki qat .map() var:

Xarici .map() — Stream-in özünü çevirir (QuerySnapshot → List<PostEntity>)
Daxili .map() — snapshot.docs (bir çox sənəd) siyahısının hər elementini ayrı-ayrı PostEntity-yə çevirir

*/