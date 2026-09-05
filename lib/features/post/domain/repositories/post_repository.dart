import 'package:connectly/features/post/domain/entities/post_entity.dart';

abstract class PostRepository {
  Future<void> createPost(
    PostEntity post,
  ); //future cunki 1 defe tek obyekt yaratmaq kifayetdi

  Stream<List<PostEntity>>
  getPosts(); //stream cunki teze postlar geldikce getirsin
  Future<void> toggleLike({required String postId, required String uid});
}
