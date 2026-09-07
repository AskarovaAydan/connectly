import 'dart:async';

import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasource/post_local_datasource.dart';
import '../datasource/post_remote_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final PostLocalDataSource localDataSource;

  PostRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<void> createPost(PostEntity post) {
    return remoteDataSource.createPost(post);
  }

  @override
  Stream<List<PostEntity>> getPosts() {
    final controller = StreamController<List<PostEntity>>();

    // 1. Əvvəlcə, cache-dən (Hive) DƏRHAL göstər (internet gözləmədən)
    localDataSource.getCachedPosts().then((cachedPosts) {
      if (cachedPosts.isNotEmpty) {
        controller.add(cachedPosts);
      }
    });

    // 2. Sonra, paralel olaraq Firestore-a qoşul, real-time yenilə + cache-i güncəllə
    remoteDataSource.getPosts().listen(
      (freshPosts) {
        localDataSource.cachePosts(
          freshPosts,
        ); // yeni data gələndə, cache-i yenilə
        controller.add(freshPosts); // UI-a göndər
      },
      onError: (e) {
        // İnternet yoxdursa, Firestore xəta verəcək
        // Bu halda, cache-də olan postlar artıq göstərilib, əlavə iş lazım deyil
        controller.addError(
          e,
        ); //Firestore-a qoşulmaq mümkün olmasa, onError işə düşür. Amma diqqət et — UI çökmür, çünki artıq addım 1-də, Hive-dan köhnə (amma mövcud) data göstərilib. İstifadəçi, "internet yoxdur" xətası əvəzinə, son gördüyü postları görməyə davam edir — bu, əsl "offline-first" təcrübədir.
      },
    );

    return controller.stream;
  }

  @override
  Future<void> toggleLike({required String postId, required String uid}) {
    return remoteDataSource.toggleLike(postId: postId, uid: uid);
  }
}
/*
final controller = StreamController<List<PostEntity>>();
İndiyə qədər, Stream-ləri hazır alırdıq (Firestore-un .snapshots() özü verirdi). 
Amma indi, iki fərqli mənbədən (Hive + Firestore) gələn data-nı bir Stream-də birləşdirmək 
istəyirik. StreamController, bizə özümüz bir Stream yaratmağa imkan verir — istədiyimiz 
vaxt, controller.add(...) ilə ora yeni data "atırıq".
*/