import 'package:hive/hive.dart';
import '../../domain/entities/post_entity.dart';
import '../models/post_hive_model.dart';

class PostLocalDataSource {
  static const String boxName = 'posts_cache';

  Future<void> cachePosts(List<PostEntity> posts) async {
    final box = await Hive.openBox<PostHiveModel>(
      boxName,
    ); //Hive-da, data "box" (qutu) adlanan konteynerlərdə saxlanılır — bunu, Firestore-un "collection"-una bənzədə bilərsən. openBox — bu qutunu açır (yoxdursa yaradır).
    await box.clear(); // köhnə cache-i təmizlə

    for (final post in posts) {
      final hiveModel = PostHiveModel(
        id: post.id,
        userId: post.userId,
        userName: post.userName,
        userPhotoUrl: post.userPhotoUrl,
        content: post.content,
        createdAt: post.createdAt.toIso8601String(),
        likedBy: post.likedBy,
      );
      await box.put(
        post.id,
        hiveModel,
      ); //Firestore-un .doc(id).set(...)-ə bənzəyir — post.id-ni açar kimi, hiveModel-i dəyər kimi saxlayır.
    }
  }

  Future<List<PostEntity>> getCachedPosts() async {
    final box = await Hive.openBox<PostHiveModel>(boxName);
    return box.values.map((hiveModel) {
      //box.values-Qutudakı bütün dəyərləri (bizim halda, bütün PostHiveModel-ləri) qaytarır — Firestore-un snapshot.docs-una bənzəyir.
      return PostEntity(
        id: hiveModel.id,
        userId: hiveModel.userId,
        userName: hiveModel.userName,
        userPhotoUrl: hiveModel.userPhotoUrl,
        content: hiveModel.content,
        createdAt: DateTime.parse(hiveModel.createdAt),
        likedBy: hiveModel.likedBy,
      );
    }).toList();
  }
}
/*
Niyə getCachedPosts-da yenidən PostEntity-yə çeviririk?
Eyni səbəb — domain qatı (Cubit, UseCase) yalnız PostEntity-ni tanımalıdır, 
PostHiveModel-i yox. Bu, "Firebase formatından domain formatına çevirmə" məntiqinin eynisidir, 
sadəcə Hive üçün.
*/